import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import Factory

public enum FeatureFlagRoute {
  case list
}

extension FeatureFlagRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .list:
      return "/v1/feature-flag/list"
    }
  }
  
  public var httpMethod: HttpMethod {
    .GET
  }
  
  public var httpHeaders: HttpHeaders {
    let base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Accept": "application/json",
      "Authorization": self.needAuthorizationKey
    ]
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .list:
      return [
        "enabled": "true"
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .list:
      return .url
    }
  }
  
}
