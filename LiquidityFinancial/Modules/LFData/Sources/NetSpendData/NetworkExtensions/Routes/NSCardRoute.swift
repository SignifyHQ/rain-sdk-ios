import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import NetspendDomain

public enum NSCardRoute {
  case listCard
  case createCard(String)
  case card(String, String)
  case lock(String, String)
  case unlock(String, String)
  case close(CloseCardReasonParameters, cardId: String, sessionId: String)
  case orderPhysicalCard(AddressCardParameters, String)
  case verifyCVVCode(VerifyCVVCodeParameters, String, String)
  case setPin(SetPinParameters, String, String)
  case getApplyPayToken(cardId: String, sessionId: String)
  case postApplyPayToken(cardId: String, sessionId: String, bodyData: [String: Any])
}

extension NSCardRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .listCard:
      return "/v1/netspend/cards"
    case .createCard:
      return "/v1/netspend/cards/virtual-card"
    case let .card(cardID, _):
      return "/v1/netspend/cards/\(cardID)"
    case let .lock(cardID, _):
      return "/v1/netspend/cards/\(cardID)/lock"
    case let .unlock(cardID, _):
      return "/v1/netspend/cards/\(cardID)/unlock"
    case let .close(_, cardID, _):
      return "/v1/netspend/cards/\(cardID)/close"
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
    case .createCard, .lock, .unlock, .close, .orderPhysicalCard, .verifyCVVCode, .postApplyPayToken: return .POST
    case .setPin: return .PUT
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
    base["Authorization"] = self.needAuthorizationKey
    switch self {
    case .listCard:
      break
    case let .createCard(sessionId),
      let .card(_, sessionId),
      let .lock(_, sessionId),
      let .unlock(_, sessionId),
      let .close(_, _, sessionId),
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
    case .listCard, .createCard, .card, .lock, .unlock, .getApplyPayToken:
      return nil
    case let .close(parameters, _, _):
      return parameters.encoded()
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
    case .listCard, .createCard, .card, .lock, .unlock, .getApplyPayToken: return nil
    case .orderPhysicalCard, .verifyCVVCode, .setPin, .postApplyPayToken, .close:
      return .json
    }
  }
  
}
