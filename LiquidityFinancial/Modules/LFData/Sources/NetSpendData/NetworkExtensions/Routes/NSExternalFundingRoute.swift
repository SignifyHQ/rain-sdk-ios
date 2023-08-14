import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager
import NetSpendDomain

public enum NSExternalFundingRoute {
  case set(ExternalCardParameters, String)
  case pinWheelToken(String)
  case getACHInfo(String)
  case getLinkedSource(sessionId: String)
  case deleteLinkedSource(sessionId: String, sourceId: String, sourceType: String)
  case newTransaction(ExternalTransactionParameters, ExternalTransactionType, String)
  case verifyCard(sessionId: String, parameters: VerifyExternalCardParameters)
}

extension NSExternalFundingRoute: LFRoute {
  
  public var authorization: String {
    let auth = AuthorizationManager()
    return auth.fetchToken()
  }
  
  public var path: String {
    switch self {
    case .set:
      return "/v1/netspend/external-funding/external-card"
    case .pinWheelToken:
      return "/v1/netspend/external-funding/pinwheel-token"
    case .getACHInfo:
      return "/v1/netspend/external-funding/ach-info"
    case .getLinkedSource:
      return "/v1/netspend/external-funding"
    case .deleteLinkedSource(_, let sourceId, let sourceType):
      if sourceType == APILinkSourceType.externalCard.rawString {
        return "/v1/netspend/external-funding/external-card/\(sourceId)"
      } else {
        return "/v1/netspend/external-funding/external-bank/\(sourceId)"
      }
    case .newTransaction(_, let type, _):
      switch type {
      case .deposit:
        return "/v1/netspend/external-funding/withdraw"
      case .withdraw:
        return "/v1/netspend/external-funding/deposit"
      }
    case .verifyCard:
      return "/v1/netspend/external-funding/external-card/verify"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getACHInfo, .getLinkedSource:
      return .GET
    case .set, .pinWheelToken:
      return .POST
    case .deleteLinkedSource:
      return .DELETE
    case .newTransaction:
      return .POST
    case .verifyCard:
      return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": self.productID
    ]
    base["Authorization"] = authorization
    switch self {
    case let .set(_, sessionId),
        let .pinWheelToken(sessionId),
        let .getACHInfo(sessionId):
      base["netspendSessionId"] = sessionId
    case .getLinkedSource(let sessionId):
      base["netspendSessionId"] = sessionId
    case .deleteLinkedSource(let sessionId, _, _):
      base["netspendSessionId"] = sessionId
    case .newTransaction(_, _, let sessionId):
      base["netspendSessionId"] = sessionId
    case .verifyCard(let sessionId, _):
      base["netspendSessionId"] = sessionId
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .set(parameters, _):
      return parameters.encoded()
    case .getACHInfo, .pinWheelToken, .getLinkedSource, .deleteLinkedSource:
      return nil
    case let .newTransaction(parameters, _, _):
      return parameters.encoded()
    case let .verifyCard(_, parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getLinkedSource, .deleteLinkedSource:
      return nil
    case .set, .verifyCard:
      return .json
    case .getACHInfo, .pinWheelToken:
      return .url
    case .newTransaction:
      return .json
    }
  }
  
}
