import Foundation
import CoreNetwork
import NetworkUtilities
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
  case getFundingStatus(sessionID: String)
  case getCardRemainingAmount(sessionID: String, type: String)
  case getBankRemainingAmount(sessionID: String, type: String)
}

extension NSExternalFundingRoute: LFRoute {
  
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
    case .newTransaction(let parameters, let type, _):
      if parameters.sourceType == APILinkSourceType.externalBank.rawString {
        switch type {
        case .deposit:
          return "/v1/netspend/external-banks/deposit"
        case .withdraw:
          return "/v1/netspend/external-banks/withdraw"
        }
      }
      switch type {
      case .deposit:
        return "/v1/netspend/external-funding/deposit"
      case .withdraw:
        return "/v1/netspend/external-funding/withdraw"
      }
    case .verifyCard:
      return "/v1/netspend/external-funding/external-card/verify"
    case .getFundingStatus:
      return "/v1/netspend/external-funding/status"
    case let .getCardRemainingAmount(_, type):
      return "/v1/netspend/external-cards/\(type)/limits"
    case let .getBankRemainingAmount(_, type):
      return "/v1/netspend/external-banks/\(type)/limits"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getACHInfo, .getLinkedSource, .getFundingStatus, .getCardRemainingAmount, .getBankRemainingAmount:
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
      "productId": NetworkUtilities.productID
    ]
    base["Authorization"] = self.needAuthorizationKey
    switch self {
    case let .set(_, sessionId),
      let .pinWheelToken(sessionId),
      let .getACHInfo(sessionId),
      let .getFundingStatus(sessionId):
      base["netspendSessionId"] = sessionId
    case .getLinkedSource(let sessionId):
      base["netspendSessionId"] = sessionId
    case .deleteLinkedSource(let sessionId, _, _):
      base["netspendSessionId"] = sessionId
    case .newTransaction(_, _, let sessionId):
      base["netspendSessionId"] = sessionId
    case .verifyCard(let sessionId, _):
      base["netspendSessionId"] = sessionId
    case .getCardRemainingAmount(let sessionId, _), .getBankRemainingAmount(let sessionId, _):
      base["netspendSessionId"] = sessionId
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .set(parameters, _):
      return parameters.encoded()
    case .getACHInfo, .pinWheelToken, .getLinkedSource, .deleteLinkedSource, .getFundingStatus, .getCardRemainingAmount, .getBankRemainingAmount:
      return nil
    case let .newTransaction(parameters, _, _):
      if parameters.sourceType == APILinkSourceType.externalBank.rawString {
        return [
          "amount": parameters.amount,
          "sourceId": parameters.sourceId
        ]
      }
      return parameters.encoded()
    case let .verifyCard(_, parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getLinkedSource, .deleteLinkedSource, .getFundingStatus, .getCardRemainingAmount, .getBankRemainingAmount:
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
