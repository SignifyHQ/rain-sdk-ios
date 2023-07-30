import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager

public enum CardRoute {
  case listCard
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
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard: return .GET
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
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .listCard:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
  switch self {
  case .listCard: return nil
  }
  }
  
}
