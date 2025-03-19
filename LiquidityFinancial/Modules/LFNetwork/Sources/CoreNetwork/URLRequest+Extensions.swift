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
        do {
          body = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
          print("Failed to serialize JSON: \(error)")
        }
        
      case .url:
        var urlComponents = URLComponents(url: route.url, resolvingAgainstBaseURL: false)
        let existingQueryItems = urlComponents?.queryItems ?? []
        
        let encodedQueryItems: [URLQueryItem] = parameters.flatMap { key, value in
          if let arrayValue = value as? [Any] {
            return arrayValue.map { element in
              URLQueryItem(name: key, value: String(describing: element))
            }
          }
          return [URLQueryItem(name: key, value: String(describing: value))]
        }
        
        urlComponents?.queryItems = existingQueryItems + encodedQueryItems
        
        if let finalURL = urlComponents?.url?.absoluteString {
          let properlyEncodedURLString = finalURL.replacingOccurrences(of: "+", with: "%2B")
          url = URL(string: properlyEncodedURLString) ?? url
        }
      }
    }
    
    self.init(url: url)
    httpMethod = route.httpMethod.rawValue
    httpBody = body
    
    if headers["Authorization"] == route.needAuthorizationKey {
      headers["Authorization"] = auth.fetchAccessToken()
    }
    
    headers.forEach { setValue($0.value, forHTTPHeaderField: $0.key) }
  }
}
