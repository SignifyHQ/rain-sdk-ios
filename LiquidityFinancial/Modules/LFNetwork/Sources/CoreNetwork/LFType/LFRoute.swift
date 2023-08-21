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
