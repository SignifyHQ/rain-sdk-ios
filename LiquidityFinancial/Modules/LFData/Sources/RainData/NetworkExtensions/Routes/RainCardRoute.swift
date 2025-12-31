import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum RainCardRoute {
  case getCards
  case getCardDetail(cardID: String)
  case getCardOrders
  case orderPhysicalCard(parameters: APIRainOrderCardParameters)
  case orderPhysicalCardWithApproval(parameters: APIRainOrderCardParameters)
  case activatePhysicalCard(cardID: String, parameters: APIRainActivateCardParameters)
  case closeCard(cardID: String)
  case lockCard(cardID: String)
  case unlockCard(cardID: String)
  case cancelOrder(cardID: String)
  case getSecretCardInfomation(sessionID: String, cardID: String)
  case createVirtualCard
}

extension RainCardRoute: LFRoute {
  public var path: String {
    switch self {
    case .getCards:
      return "/v1/rain/cards/list"
    case .getCardDetail:
      return "/v1/rain/cards/by-id"
    case .getCardOrders:
      return "/v1/rain/cards/physical-card/orders"
    case .orderPhysicalCard:
      return "/v1/rain/cards/physical-card"
    case .orderPhysicalCardWithApproval:
      return "/v1/rain/cards/physical-card/order"
    case let .activatePhysicalCard(cardID, _):
      return "/v1/rain/cards/physical-card/activate?card_id=\(cardID)"
    case .closeCard:
      return "/v1/rain/cards/close"
    case .lockCard:
      return "/v1/rain/cards/lock"
    case .unlockCard:
      return "/v1/rain/cards/unlock"
    case let .cancelOrder(cardID):
      return "/v1/rain/cards/physical-card/orders/\(cardID)/cancel"
    case .getSecretCardInfomation:
      return "/v1/rain/cards/card-secret-info-by-id"
    case .createVirtualCard:
      return "/v1/rain/cards/virtual-card"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getCards, .getCardOrders, .getSecretCardInfomation, .getCardDetail:
      return .GET
    case .orderPhysicalCard,
        .orderPhysicalCardWithApproval,
        .activatePhysicalCard,
        .closeCard,
        .lockCard,
        .unlockCard,
        .cancelOrder,
        .createVirtualCard:
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
    
    switch self {
    case let .getSecretCardInfomation(sessionID, _):
      base["sessionId"] = sessionID
    default: break
    }
    
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .getCards:
      return [
        "limit": Constants.defaultLimit
      ]
    case let .closeCard(cardID),
      let .lockCard(cardID),
      let .unlockCard(cardID),
      let .getSecretCardInfomation(_, cardID),
      let .getCardDetail(cardID):
      return [
        "card_id": cardID
      ]
    case let .orderPhysicalCard(parameters), let .orderPhysicalCardWithApproval(parameters):
      return parameters.encoded()
    case let .activatePhysicalCard(_, parameters):
      return parameters.encoded()
    case .getCardOrders, .cancelOrder, .createVirtualCard:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getCards,
        .getCardDetail,
        .closeCard,
        .lockCard,
        .unlockCard,
        .getSecretCardInfomation:
      return .url
    case .orderPhysicalCard, .orderPhysicalCardWithApproval, .activatePhysicalCard:
      return .json
    case .getCardOrders, .cancelOrder, .createVirtualCard:
      return nil
    }
  }
}
