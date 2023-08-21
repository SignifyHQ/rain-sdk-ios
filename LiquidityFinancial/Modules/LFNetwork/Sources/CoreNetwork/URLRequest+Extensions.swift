import Foundation
import AuthorizationManager

// swiftlint:disable all

extension URLRequest {
  
  init(route: LFRoute, auth: AuthorizationManagerProtocol) {
    var url = route.url
    var headers = route.httpHeaders
    var body: Data?
    
    if let parameters = route.parameters, let parameterEncoding = route.parameterEncoding {
      switch parameterEncoding {
      case .json:
        if let data = try? JSONSerialization.data(withJSONObject: parameters) {
          body = data
        }
      case .url:
        var urlComponents = URLComponents(url: route.url, resolvingAgainstBaseURL: false)
        let queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
          // TODO: Handling casting `parameters`' values properly (i.e. `Any` to `String`)
        let encodedQueryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
        urlComponents?.queryItems = queryItems + encodedQueryItems
        url = urlComponents?.url ?? url
      }
    }
    
    self.init(url: url)
    httpMethod = route.httpMethod.rawValue
    httpBody = body
    if let value = headers["Authorization"], value == route.needAuthorizationKey {
      headers["Authorization"] = auth.fetchAccessToken()
    }
    headers.forEach { setValue($0.value, forHTTPHeaderField: $0.key) }
  }
}
