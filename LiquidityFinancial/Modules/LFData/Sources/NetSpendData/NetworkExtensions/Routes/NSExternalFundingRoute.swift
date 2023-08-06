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
  case deleteLinkedSource(sessionId: String, sourceId: String)
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
    case .deleteLinkedSource(_, let sourceId):
      return "/v1/netspend/external-funding/external-card/\(sourceId)"
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
    case .deleteLinkedSource(let sessionId, _):
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
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getLinkedSource, .deleteLinkedSource:
      return nil
    case .set:
      return .json
    case .getACHInfo, .pinWheelToken:
      return .url
    }
  }
  
}
