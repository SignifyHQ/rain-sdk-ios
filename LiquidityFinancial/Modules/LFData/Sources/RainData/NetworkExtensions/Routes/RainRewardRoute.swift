import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum RainRewardRoute {
  case getRewardBalance
}

extension RainRewardRoute: LFRoute {
  public var path: String {
    switch self {
    case .getRewardBalance:
      return "/v1/rain/rewards/balances"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getRewardBalance:
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
    case .getRewardBalance:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getRewardBalance:
      return nil
    }
  }
}
