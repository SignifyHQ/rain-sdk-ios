import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum SolidExternalFundingRoute {
  case getLinkedSources(accountId: String)
  case createDebitCardToken(accountID: String)
  case createPlaidToken(accountId: String)
  case plaidLink(accountId: String, token: String, plaidAccountId: String)
}

extension SolidExternalFundingRoute: LFRoute {

  public var path: String {
    switch self {
    case .getLinkedSources:
      return "/v1/solid/external-funding/linked-sources"
    case .createDebitCardToken:
      return "/v1/solid/external-funding/linked-sources/debit-card/token"
    case .createPlaidToken:
      return "/v1/solid/external-funding/linked-sources/plaid/token"
    case .plaidLink:
      return "/v1/solid/external-funding/linked-sources/plaid/link"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getLinkedSources:
      return .GET
    case .createDebitCardToken, .createPlaidToken, .plaidLink:
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
    case .getLinkedSources(let accountId):
      return [
        "accountId": accountId
      ]
    case .createDebitCardToken(let accountID):
      return [
        "liquidityAccountId": accountID
      ]
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
    switch self {
    case .createDebitCardToken, .createPlaidToken, .plaidLink:
      return .json
    case .getLinkedSources:
      return .url
    }
  }
  
}
