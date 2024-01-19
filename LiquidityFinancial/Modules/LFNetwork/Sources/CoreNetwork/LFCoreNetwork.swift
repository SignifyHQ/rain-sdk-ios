import Foundation
import Combine
import Alamofire
import AuthorizationManager
import Factory
import UniformTypeIdentifiers
import LFUtilities
import LFLocalizable

public protocol CoreNetworkType {
  
  associatedtype R: LFRoute
  
  func requestCombine(_ route: R) -> AnyPublisher<Data?, AFError>
  func requestCombine<T>(_ route: R, target: T.Type, decoder: JSONDecoder) -> AnyPublisher<T, AFError> where T: Decodable
  
  func request(_ route: R) async throws -> Response
  func request<T>(_ route: R, target: T.Type, decoder: JSONDecoder) async throws -> T where T: Decodable
  func request<T, E>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder) async throws -> T where T: Decodable, E: DesignatedError
  func requestNoResponse<E>(_ route: R, failure: E.Type, decoder: JSONDecoder) async throws where E: Decodable, E: Error
  func download(_ route: R, fileName: String, type: UTType) async throws -> URL
}

public final class LFCoreNetwork<R: LFRoute>: CoreNetworkType {
  
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  var configuration: URLSessionConfiguration {
    session.sessionConfiguration
  }
  
  private let session: Session
  private let authInterceptor: AuthenticationInterceptor<OAuthAuthenticator>
  
  public init(configuration: URLSessionConfiguration, interceptor: RequestInterceptor? = nil, eventMonitor: [EventMonitor] = []) {
    var monitors = eventMonitor
    monitors.append(LogMonitor())
    let authenticator = OAuthAuthenticator()
    authInterceptor = AuthenticationInterceptor(authenticator: authenticator, credential: nil)
    session = Session(configuration: configuration, interceptor: interceptor, eventMonitors: monitors)
    
    authenticator.delegate = self
  }
  
  public convenience init(interceptor: RequestInterceptor? = nil, eventMonitor: [EventMonitor] = []) {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 60
    configuration.timeoutIntervalForResource = 60
    let diskCapacity = 30 * 1_024 * 1_024
    configuration.urlCache = .init(memoryCapacity: configuration.urlCache?.memoryCapacity ?? 0, diskCapacity: diskCapacity)
    
    URLSessionConfiguration.mockingswizzleDefaultSessionConfiguration()
    
    self.init(configuration: configuration, interceptor: interceptor, eventMonitor: eventMonitor)
  }
  
  public func requestCombine(_ route: R) -> AnyPublisher<Data?, AFError> {
    let request = LFURLRequest(route: route, auth: authorizationManager)
    let dataRequest = session.request(request, interceptor: buildInterceptor(from: route))
    return dataRequest.validate().publishUnserialized().value().eraseToAnyPublisher()
  }
  
  public func requestCombine<T>(_ route: R, target: T.Type, decoder: JSONDecoder) -> AnyPublisher<T, AFError> where T: Decodable {
    let request = LFURLRequest(route: route, auth: authorizationManager)
    let dataRequest = session.request(request, interceptor: buildInterceptor(from: route))
    return dataRequest.validate().publishDecodable(type: target).value().eraseToAnyPublisher()
  }
  
  public func requestNonAuth(_ route: R) async throws -> Response {
    let request = LFURLRequest(route: route, auth: authorizationManager)
    let dataResponse = await AF.request(request).validate().serializingData().response
    return Response(httpResponse: dataResponse.response, data: dataResponse.data)
  }
  
  public func request(_ route: R) async throws -> Response {
    let request = LFURLRequest(route: route, auth: authorizationManager)
    let dataRequest = session.request(request, interceptor: buildInterceptor(from: route))
    let stringResponse = await dataRequest.validate().serializingData().response
    
    if !(stringResponse.response?.statusCode ?? 500).isSuccess, let error = stringResponse.error {
      let errorMessage = error.isSessionTaskError ? LFLocalizable.internetConnectionErrorMessage : error.localizedDescription
      throw LFNetworkError.custom(message: errorMessage)
    }
    
    return Response(httpResponse: stringResponse.response, data: stringResponse.data)
  }
  
  public func request<T>(_ route: R, target: T.Type, decoder: JSONDecoder) async throws -> T where T: Decodable {
    let request = LFURLRequest(route: route, auth: authorizationManager)
    let dataRequest = session.request(request, interceptor: buildInterceptor(from: route))
    let response = await dataRequest.validate().serializingDecodable(target).response
    if let value = response.value {
      return value
    }
    if let data = response.data {
      throw try decodeError(failure: LFErrorObject.self, from: data, decoder: decoder)
    }
    guard let error = response.error else {
      throw LFNetworkError.custom(message: "Unknown error")
    }
    
    let errorMessage = error.isSessionTaskError ? LFLocalizable.internetConnectionErrorMessage : error.localizedDescription
    throw LFNetworkError.custom(message: errorMessage)
  }
  
  public func request<T, E>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder) async throws -> T where T: Decodable, E: Decodable, E: Error {
    let request = LFURLRequest(route: route, auth: authorizationManager)
    let dataRequest = session.request(request, interceptor: buildInterceptor(from: route))
    let response = await dataRequest.validate().serializingDecodable(target).response
    if let value = response.value {
      return value
    }
    if let data = response.data {
      throw try decodeError(failure: failure, from: data, decoder: decoder)
    }
    guard let error = response.error else {
      throw LFNetworkError.custom(message: "Unknown error")
    }
    
    let errorMessage = error.isSessionTaskError ? LFLocalizable.internetConnectionErrorMessage : error.localizedDescription
    throw LFNetworkError.custom(message: errorMessage)
  }
  
  public func requestNoResponse<E>(_ route: R, failure: E.Type, decoder: JSONDecoder) async throws where E: Decodable, E: Error {
    let request = LFURLRequest(route: route, auth: authorizationManager)
    let dataRequest = session.request(request, interceptor: buildInterceptor(from: route))
    let response = await dataRequest.validate().serializingData().response
    if (response.response?.statusCode ?? 500).isSuccess {
      return
    }
    if let data = response.data {
      throw try decodeError(failure: failure, from: data, decoder: decoder)
    }
    guard let error = response.error else {
      throw LFNetworkError.custom(message: "Unknown error")
    }
    
    let errorMessage = error.isSessionTaskError ? LFLocalizable.internetConnectionErrorMessage : error.localizedDescription
    throw LFNetworkError.custom(message: errorMessage)
  }
  
  public func download(_ route: R, fileName: String, type: UTType = .pdf) async throws -> URL {
    let request = LFURLRequest(route: route, auth: authorizationManager)
    let downloadRequest = session.download(request, interceptor: buildInterceptor(from: route)) { temporaryURL, _ in
      let fileManager = FileManager.default
      let options: DownloadRequest.Options = [.createIntermediateDirectories, .removePreviousFile]
      
      if let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        return (directoryURL.appendingPathComponent(fileName, conformingTo: type), options)
      }
      
      return (temporaryURL, options)
    }
    
    let response = await downloadRequest.validate().serializingDownloadedFileURL().response
    
    if let value = response.value {
      return value
    }
    
    guard let error = response.error else {
      throw LFNetworkError.custom(message: "Unknown error")
    }
    
    let errorMessage = error.isSessionTaskError ? LFLocalizable.internetConnectionErrorMessage : error.localizedDescription
    throw LFNetworkError.custom(message: errorMessage)
  }
}

extension LFCoreNetwork: AuthenticatorDelegate {
  public func requestTokens(with tokens: OAuthCredential, completion: @escaping (Result<OAuthCredential, Error>) -> Void) {
    authorizationManager.refresh(with: tokens, completion: completion)
  }
}

extension LFCoreNetwork {
  private func buildInterceptor(from route: R) -> Interceptor? {
    let mustAuthorization = route.httpHeaders.contains(where: { key, _ in
      key == "Authorization" ? true : false
    })
    if mustAuthorization {
      let adapters: [RequestAdapter] = []
      var interceptors: [RequestInterceptor] = [RetryPolicy()]
      
      if let tokens = authorizationManager.fetchTokens() {
        authInterceptor.credential = tokens
        interceptors.append(authInterceptor)
      }
      return Interceptor(adapters: adapters, retriers: [], interceptors: interceptors)
    }
    return nil
  }
  
  private func decodeError<E>(failure: E.Type, from data: Data, decoder: JSONDecoder) throws -> E where E: DesignatedError {
    let designatedError: DesignatedError
    do {
      designatedError = try decoder.decode(E.self, from: data)
    } catch {
      if let errorString = data.prettyPrintedJSONString as? String {
        if let message = errorString.components(separatedBy: ",").first {
          throw LFNetworkError.custom(message: message.replace(string: "{", replacement: ""))
        }
        throw LFNetworkError.custom(message: errorString)
      } else {
        throw LFNetworkError.custom(message: "Decoder error object is failed")
      }
    }
    throw designatedError
  }
  
  public static func processingStringError(_ data: Data) throws {
    if let errorString = data.prettyPrintedJSONString as? String {
      if let message = errorString.components(separatedBy: ",").first {
        throw LFNetworkError.custom(message: message.replace(string: "{", replacement: ""))
      }
      throw LFNetworkError.custom(message: errorString)
    } else {
      throw LFNetworkError.custom(message: "Decoder error object is failed")
    }
  }
}
