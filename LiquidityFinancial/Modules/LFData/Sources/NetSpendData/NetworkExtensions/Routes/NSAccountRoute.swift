import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import NetspendDomain

public enum NSAccountRoute {
  case getStatements(sessionId: String, parameters: GetStatementParameters)
}

extension NSAccountRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .getStatements:
      return "/v1/netspend/accounts/statements"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getStatements: return .GET
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
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .getStatements(_, parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getStatements:
      return .url
    }
  }
  
}
