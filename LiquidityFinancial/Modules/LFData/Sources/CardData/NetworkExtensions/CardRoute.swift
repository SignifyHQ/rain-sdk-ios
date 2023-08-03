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
  case orderPhysicalCard(AddressCardParameters, String)
  case verifyCVVCode(VerifyCVVCodeParameters, String, String)
  case setPin(SetPinParameters, String, String)
  case getApplyPayToken(cardId: String, sessionId: String)
  case postApplyPayToken(cardId: String, sessionId: String, bodyData: [String: Any])
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
    case let .getApplyPayToken(cardID, _):
      return "/v1/netspend/cards/\(cardID)/apple-pay/token/"
    case let .postApplyPayToken(cardID, _, _):
      return "/v1/netspend/cards/\(cardID)/apple-pay/token/"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard, .card, .getApplyPayToken: return .GET
    case .lock, .unlock, .orderPhysicalCard, .verifyCVVCode, .postApplyPayToken: return .POST
    case .setPin: return .PUT
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": self.productID
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
      let .setPin(_, _, sessionId),
      let .getApplyPayToken(_, sessionId),
      let .postApplyPayToken(_, sessionId, _):
      base["netspendSessionId"] = sessionId
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .listCard, .card, .lock, .unlock, .getApplyPayToken:
      return nil
    case let .orderPhysicalCard(parameters, _):
      var wrapBody: [String: Any] = [:]
      wrapBody["shippingAddress"] = parameters.encoded()
      return wrapBody
    case let .verifyCVVCode(parameters, _, _):
      return parameters.encoded()
    case let .setPin(parameters, _, _):
      return parameters.encoded()
    case let .postApplyPayToken(_, _, parameters):
      return parameters
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .listCard, .card, .lock, .unlock, .getApplyPayToken: return nil
    case .orderPhysicalCard, .verifyCVVCode, .setPin, .postApplyPayToken:
      return .json
    }
  }
  
}
