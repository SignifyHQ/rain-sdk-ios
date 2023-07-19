import LFNetwork
import Foundation
import DataUtilities
import AuthorizationManager

public enum NetSpendRoute {
  case sessionInit
  case establishSession(EstablishSessionParameters)
}

extension NetSpendRoute: LFRoute {
  
  var authorization: String {
    let auth = AuthorizationManager()
    return auth.fetchToken()
  }
  
  public var path: String {
    switch self {
    case .sessionInit:
      return "/v1/netspend/sessions/init"
    case .establishSession:
      return "/v1/netspend/sessions"
    }
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": authorization,
      "productName": APIConstants.productNameDefault,
      "productId": APIConstants.productID
    ]
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .sessionInit:
      return HttpMethod.GET
    case .establishSession:
      return HttpMethod.POST
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .sessionInit:
      return nil
    case .establishSession(let parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .sessionInit:
      return nil
    case .establishSession:
      return .json
    }
  }
  
}
