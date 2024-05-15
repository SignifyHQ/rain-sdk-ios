import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum RainCardRoute {
  case getCards
  case orderPhysicalCard(parameters: APIRainOrderCardParameters)
  case activatePhysicalCard(cardID: String, parameters: APIRainActivateCardParameters)
  case closeCard(cardID: String)
  case lockCard(cardID: String)
  case unlockCard(cardID: String)
}

extension RainCardRoute: LFRoute {
  public var path: String {
    switch self {
    case .getCards:
      return "/v1/rain/cards/list"
    case .orderPhysicalCard:
      return "/v1/rain/cards/physical-card"
    case let .activatePhysicalCard(cardID, _):
      return "/v1/rain/cards/physical-card/activate?card_id=\(cardID)"
    case .closeCard:
      return "/v1/rain/cards/close"
    case .lockCard:
      return "/v1/rain/cards/lock"
    case .unlockCard:
      return "/v1/rain/cards/unlock"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getCards:
      return .GET
    case .orderPhysicalCard,
        .activatePhysicalCard,
        .closeCard,
        .lockCard,
        .unlockCard:
      return .POST
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
    case let .closeCard(cardID), let .lockCard(cardID), let .unlockCard(cardID):
      return [
        "card_id": cardID
      ]
    case let .orderPhysicalCard(parameters):
      return parameters.encoded()
    case let .activatePhysicalCard(_, parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getCards, .closeCard, .lockCard, .unlockCard:
      return .url
    case .orderPhysicalCard, .activatePhysicalCard:
      return .json
    }
  }
}
