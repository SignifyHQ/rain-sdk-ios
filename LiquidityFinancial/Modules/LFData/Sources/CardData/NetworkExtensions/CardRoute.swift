import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager

public enum CardRoute {
  case listCard
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
    case .listCard: return .GET
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
    case let .lock(_, sessionId),
      let .unlock(_, sessionId),
      let .orderPhysicalCard(_, sessionId):
      base["netspendSessionId"] = sessionId
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .listCard, .lock, .unlock:
      return nil
    case let .orderPhysicalCard(parameters, _):
      let acde = parameters.encoded()
      return acde
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .listCard, .lock, .unlock: return nil
    case .orderPhysicalCard:
      return .json
    }
  }
  
}
