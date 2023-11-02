import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities
import SolidDomain

public enum SolidCardRoute {
  case listCard
  case updateCardStatus(cardID: String, parameters: APISolidCardStatusParameters)
}

extension SolidCardRoute: LFRoute {

  public var path: String {
    switch self {
    case .listCard:
      return "/v1/solid/cards"
    case let .updateCardStatus(cardID, _):
      return "/v1/solid/cards/\(cardID)/status"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard:
      return .GET
    case .updateCardStatus:
      return .PATCH
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
    case let .updateCardStatus(_, parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .listCard:
      return nil
    case .updateCardStatus:
      return .json
    }
  }
  
}
