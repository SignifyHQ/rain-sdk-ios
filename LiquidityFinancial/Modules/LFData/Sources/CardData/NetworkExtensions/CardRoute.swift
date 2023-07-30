import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager

public enum CardRoute {
  case listCard
  case lock(String, String)
  case unlock(String, String)
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
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard: return .GET
    case .lock, .unlock: return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": APIConstants.productID
    ]
    switch self {
    case .listCard:
      base["Authorization"] = authorization
      return base
    case let .lock(_, sessionId), let .unlock(_, sessionId):
      base["Authorization"] = authorization
      base["netspendSessionId"] = sessionId
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .listCard, .lock, .unlock:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
  switch self {
  case .listCard, .lock, .unlock: return nil
  }
  }
  
}
