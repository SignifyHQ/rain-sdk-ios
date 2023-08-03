import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager
import CardDomain

public enum ExternalFundingRoute {
  case set(ExternalCardParameters, String)
}

extension ExternalFundingRoute: LFRoute {
  
  public var authorization: String {
    let auth = AuthorizationManager()
    return auth.fetchToken()
  }
  
  public var path: String {
    switch self {
    case .set:
      return "/v1/netspend/external-funding/external-card"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .set:
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
    case let .set(_, sessionId):
      base["netspendSessionId"] = sessionId
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .set(parameters, _):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .set:
      return .json
    }
  }
  
}
