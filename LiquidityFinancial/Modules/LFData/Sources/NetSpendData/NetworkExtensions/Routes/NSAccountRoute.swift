import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import NetspendDomain

public enum NSAccountRoute {
  case getStatements(sessionId: String, parameters: GetStatementParameters)
  case getAccounts
}

extension NSAccountRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .getStatements:
      return "/v1/netspend/accounts/statements"
    case .getAccounts:
      return "/v1/netspend/accounts"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getStatements, .getAccounts:
      return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
    base["Authorization"] = self.needAuthorizationKey
    switch self {
    case let .getStatements(sessionId, _):
      base["netspendSessionId"] = sessionId
    default:
      break
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .getStatements(_, parameters):
      return parameters.encoded()
    default:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getStatements:
      return .url
    default:
      return .none
    }
  }
  
}
