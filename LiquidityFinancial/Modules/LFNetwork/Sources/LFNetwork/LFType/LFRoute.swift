import Foundation

public protocol LFRoute {
  var baseURL: URL { get }
  var path: String { get }
  var scheme: String { get }
  var httpMethod: HttpMethod { get }
  var httpHeaders: HttpHeaders { get }
  var parameters: Parameters? { get }
  var parameterEncoding: ParameterEncoding? { get }
}

extension LFRoute {
  public var scheme: String {
    "https"
  }
  
  public var url: URL {
    guard !path.isEmpty else {
      return baseURL
    }
    return baseURL.appendingPathComponent(path)
  }
  
}
