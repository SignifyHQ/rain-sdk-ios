import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities
import SolidDomain

public enum SolidCardRoute {
  case listCard
}

extension SolidCardRoute: LFRoute {

  public var path: String {
    switch self {
    case .listCard:
      return "/v1/solid/cards"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard:
      return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Authorization": self.needAuthorizationKey,
      "Accept": "application/json",
      "ld-device-id": LFUtilities.deviceId
    ]
  }
  
  public var parameters: Parameters? {
    switch self {
    case .listCard:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .listCard:
      return nil
    }
  }
  
}
