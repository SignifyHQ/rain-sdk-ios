import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum SolidRoute {
  case createPlaidToken(accountId: String)
  case plaidLink(accountId: String, token: String, plaidAccountId: String)
}

extension SolidRoute: LFRoute {

  public var path: String {
    switch self {
    case .createPlaidToken:
      return "/v1/solid/external-funding/linked-sources/plaid/token"
    case .plaidLink:
      return "/v1/solid/external-funding/linked-sources/plaid/link"
    }
  }
  
  public var httpMethod: HttpMethod {
    return .POST
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
    case .plaidLink(let accountId, let token, let plaidAccountId):
      return [
        "liquidityAccountId": accountId,
        "publicToken": token,
        "plaidAccountId": plaidAccountId
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    return .json
  }
  
}
