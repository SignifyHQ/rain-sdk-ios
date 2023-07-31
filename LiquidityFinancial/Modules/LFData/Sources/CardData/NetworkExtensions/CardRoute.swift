import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager

public enum CardRoute {
  case listCard
  case card(String, String)
  case lock(String, String)
  case unlock(String, String)
  case orderPhysicalCard(OrderPhysicalCardParameters, String)
}

extension CardRoute: LFRoute {
  
  public var authorization: String {
    let auth = AuthorizationManager()
    return auth.fetchToken()
  }
  
  public var path: String {
    switch self {
    case .listCard:
      return "/v1/netspend/cards"
    case let .card(cardID, _):
      return "/v1/netspend/cards/\(cardID)"
    case let .lock(cardID, _):
      return "/v1/netspend/cards/\(cardID)/lock"
    case let .unlock(cardID, _):
      return "/v1/netspend/cards/\(cardID)/unlock"
    case .orderPhysicalCard:
      return "/v1/netspend/cards/physical-card"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard, .card: return .GET
    case .lock, .unlock, .orderPhysicalCard: return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": APIConstants.productID
    ]
    base["Authorization"] = authorization
    switch self {
    case .listCard:
      break
    case let .card(_, sessionId),
        let .lock(_, sessionId),
        let .unlock(_, sessionId),
        let .orderPhysicalCard(_, sessionId):
      base["Authorization"] = authorization
      base["netspendSessionId"] = sessionId
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .listCard, .card, .lock, .unlock:
      return nil
    case let .orderPhysicalCard(parameters, _):
      let acde = parameters.encoded()
      return acde
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .listCard, .card, .lock, .unlock: return nil
    case .orderPhysicalCard:
      return .json
    }
  }
  
}
