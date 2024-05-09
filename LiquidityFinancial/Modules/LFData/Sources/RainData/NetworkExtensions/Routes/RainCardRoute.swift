import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum RainCardRoute {
  case getCards
}

extension RainCardRoute: LFRoute {
  public var path: String {
    switch self {
    case .getCards:
      return "/v1/rain/cards/list"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getCards:
      return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "ld-device-id": LFUtilities.deviceId
    ]
    base["Authorization"] = self.needAuthorizationKey
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .getCards:
      return [
        "limit": Constants.defaultLimit
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getCards:
      return .url
    }
  }
}
