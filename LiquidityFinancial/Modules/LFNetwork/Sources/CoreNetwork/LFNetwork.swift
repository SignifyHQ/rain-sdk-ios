import Combine
import Foundation
import LFUtilities
import AuthorizationManager
import Factory
import NetworkUtilities

public class LFNetwork<R: LFRoute>: NetworkType {
  
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  public var configuration: URLSessionConfiguration {
    session.configuration
  }
  
  public let session: URLSession
  
  public init(configuration: URLSessionConfiguration = .default) {
    URLSessionConfiguration.mockingswizzleDefaultSessionConfiguration()
    self.session = URLSession(configuration: configuration)
  }
}

extension LFNetwork {
  
  public func requestCombine(_ route: R) -> AnyPublisher<Response, LFNetworkError> {
    let request = URLRequest(route: route, auth: authorizationManager)
    Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")
    
    return session.dataTaskPublisher(for: request)
      .handleEvents(receiveOutput: processResponse)
      .map {
        Response(
          httpResponse: $1 as? HTTPURLResponse,
          data: $0
        )
      }
      .mapError(processError)
      .handleEvents(receiveCompletion: {
        if case let .failure(error) = $0 {
          Self.debugLog(error: error)
        }
      })
      .eraseToAnyPublisher()
  }
  
  public func requestCombine<T: Decodable>(_ route: R, target: T.Type, decoder: JSONDecoder = .init()) -> AnyPublisher<T, LFNetworkError> {
    let request = URLRequest(route: route, auth: authorizationManager)
    Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")
    
    return session.dataTaskPublisher(for: request)
      .handleEvents(receiveOutput: processResponse)
      .map(\.data)
      .decode(type: T.self, decoder: decoder)
      .mapError(processError)
      .handleEvents(receiveCompletion: {
        if case let .failure(error) = $0 {
          Self.debugLog(error: error)
        }
      })
      .eraseToAnyPublisher()
  }
  
  public func requestCombine<T: Decodable, E: DesignatedError>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder = .init()) -> AnyPublisher<T, LFNetworkError> {
    let request = URLRequest(route: route, auth: authorizationManager)
    Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")
    
    return session.dataTaskPublisher(for: request)
      .handleEvents(receiveOutput: processResponse)
      .tryMap { data, _ in
        try self.decodeApi(target: T.self, failure: E.self, from: data, decoder: decoder)
      }
      .mapError(processError)
      .handleEvents(receiveCompletion: {
        if case let .failure(error) = $0 {
          Self.debugLog(error: error)
        }
      })
      .eraseToAnyPublisher()
  }
}

extension LFNetwork {
  
  public func request(_ route: R, shouldcheckAuthorized: Bool = true) async throws -> Response {
    let request = URLRequest(route: route, auth: authorizationManager)
    Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")
    
    do {
      let (data, response) = try await session.data(for: request)
      self.processResponse(data: data, response: response)
      
      if shouldcheckAuthorized, checkAuthorizedAndRun(data: data, response: response) {
        try await authorizationManager.refreshToken()
        let (data, response) = try await session.data(for: request)
        self.processResponse(data: data, response: response)
        return Response(httpResponse: response as? HTTPURLResponse, data: data)
      } else {
        return Response(httpResponse: response as? HTTPURLResponse, data: data)
      }
    } catch {
      Self.debugLog(error: error)
      throw processError(error)
    }
  }
  
  public func request<T>(_ route: R, target: T.Type, decoder: JSONDecoder, shouldcheckAuthorized: Bool = true) async throws -> T where T: Decodable {
    let request = URLRequest(route: route, auth: authorizationManager)
    Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")
    
    do {
      let (data, response) = try await session.data(for: request)
      self.processResponse(data: data, response: response)
      
      if shouldcheckAuthorized, checkAuthorizedAndRun(data: data, response: response) {
        try await authorizationManager.refreshToken()
        let (data, response) = try await session.data(for: request)
        self.processResponse(data: data, response: response)
        return try decoder.decode(T.self, from: data)
      } else {
        return try decoder.decode(T.self, from: data)
      }
    } catch {
      Self.debugLog(error: error)
      throw processError(error)
    }
  }
  
  public func request<T, E>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder, shouldcheckAuthorized: Bool = true) async throws -> T where T: Decodable, E: DesignatedError {
    let request = URLRequest(route: route, auth: authorizationManager)
    Self.debugLog(info: "Request: \(request)\n\(request.allHTTPHeaderFields ?? [:])")
    
    do {
      let (data, response) = try await session.data(for: request)
      self.processResponse(data: data, response: response)
      
      if shouldcheckAuthorized, checkAuthorizedAndRun(data: data, response: response) {
        try await authorizationManager.refreshToken()
        let (data, response) = try await session.data(for: request)
        self.processResponse(data: data, response: response)
        return try decodeApi(target: T.self, failure: E.self, from: data, decoder: decoder)
      } else {
        return try decodeApi(target: T.self, failure: E.self, from: data, decoder: decoder)
      }
    } catch {
      Self.debugLog(error: error)
      throw processError(error)
    }
  }
}

extension LFNetwork {
  
  private func checkAuthorizedAndRun(data: Data, response: URLResponse) -> Bool {
    if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == APIConstants.StatusCodes.unauthorized {
      return true
    }
    return false
  }
  
  private func processResponse(data: Data, response: URLResponse) {
    let statusCode = (response as? HTTPURLResponse)?.statusCode
    let codeString = statusCode != nil ? "\(statusCode ?? 500) " : ""
    Self.debugLog(info: "Response: \n\(codeString)\(String(decoding: data, as: UTF8.self))")
  }
  
  private func processError(_ error: Error) -> LFNetworkError {
    switch error {
    case is DecodingError:
      return .decoding
    case let designatedError as DesignatedError:
      return .designated(designatedError)
    default:
      return .underlying(error)
    }
  }
  
  private func decodeApi<T, E>(target: T.Type, failure: E.Type, from data: Data, decoder: JSONDecoder) throws -> T where T: Decodable, E: DesignatedError {
    do {
      return try decoder.decode(T.self, from: data)
    } catch let decodingError {
      let designatedError: DesignatedError
      do {
        designatedError = try decoder.decode(E.self, from: data)
      } catch {
        throw decodingError
      }
      
      throw designatedError
    }
  }
}

// swiftlint:disable print_expression
extension LFNetwork {
  
  private static func debugLog(info: String) {
#if DEBUG
    log.info("[Pilot][INFO] \(info)")
#endif
  }
  
  private static func debugLog(error: Error) {
#if DEBUG
    log.error("[Pilot][ERROR] \(error.localizedDescription)")
#endif
  }
}
