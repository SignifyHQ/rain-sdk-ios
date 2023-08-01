import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager
import CardDomain

public enum CardRoute {
  case listCard
  case card(String, String)
  case lock(String, String)
  case unlock(String, String)
  case orderPhysicalCard(PhysicalCardAddressEntity, String)
  case verifyCVVCode(VerifyCVVCodeParameters, String, String)
  case setPin(SetPinParameters, String, String)
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
    case let .verifyCVVCode(_, cardID, _):
      return "/v1/netspend/cards/\(cardID)/verify"
    case let .setPin(_, cardID, _):
      return "/v1/netspend/cards/\(cardID)/pin"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard, .card: return .GET
    case .lock, .unlock, .orderPhysicalCard, .verifyCVVCode: return .POST
    case .setPin: return .PUT
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
        let .orderPhysicalCard(_, sessionId),
        let .verifyCVVCode(_, _, sessionId),
        let .setPin(_, _, sessionId):
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
    case let .verifyCVVCode(parameters, _, _):
      return parameters.encoded()
    case let .setPin(parameters, _, _):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .listCard, .card, .lock, .unlock: return nil
    case .orderPhysicalCard, .verifyCVVCode, .setPin:
      return .json
    }
  }
  
}
