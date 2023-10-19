import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum SolidRoute {
  case createPlaidToken(accountId: String)
}

extension SolidRoute: LFRoute {

  public var path: String {
    switch self {
    case .createPlaidToken:
      return "/v1/solid/external-funding/linked-sources/plaid/token"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .createPlaidToken:
      return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Authorization": self.needAuthorizationKey,
      "Accept": "application/json"
    ]
  }
  
  public var parameters: Parameters? {
    switch self {
    case .createPlaidToken(let id):
      return [
        "liquidityAccountId": id
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .createPlaidToken:
      return .json
    }
  }
  
}
