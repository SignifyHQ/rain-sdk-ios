import Foundation
import Alamofire
import Factory
import AuthorizationManager

protocol URLRequestConvertible: Alamofire.URLRequestConvertible {
  func asURLRequest() throws -> URLRequest
}

struct LFURLRequest {
  
  let request: URLRequest
  init(route: LFRoute, auth: AuthorizationManagerProtocol) {
    self.request = URLRequest(route: route, auth: auth)
  }
  
}

// MARK: URLRequestConvertible
extension LFURLRequest: URLRequestConvertible {
  func asURLRequest() throws -> URLRequest {
    let url = try asURL()
    var afRequest = try URLRequest(url: url, method: asHTTPMethod(), headers: request.headers)
    afRequest.httpBody = request.httpBody
    return afRequest
  }
}

// MARK: URLConvertible
extension LFURLRequest: URLConvertible {
  func asURL() throws -> URL {
    guard let url = request.url else {
      throw LFNetworkError.custom(message: "Invalid url for: \(self)")
    }
    return url
  }
  
  func asHTTPMethod() throws -> Alamofire.HTTPMethod {
    guard let method = request.httpMethod else {
      throw LFNetworkError.custom(message: "Invalid method for: \(request.httpMethod ?? "Not found method")")
    }
    return Alamofire.HTTPMethod(rawValue: method)
  }
}

