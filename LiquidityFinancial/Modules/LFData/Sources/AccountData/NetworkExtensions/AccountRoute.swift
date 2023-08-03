import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager

public enum AccountRoute {
  case createZeroHashAccount
  case getUser(deviceId: String)
  case getAccount(currencyType: String)
  case getTransactions(accountId: String, currencyType: String, limit: Int, offset: Int)
}

extension AccountRoute: LFRoute {
  
  public var authorization: String {
    let auth = AuthorizationManager()
    return auth.fetchToken()
  }
  
  public var path: String {
    switch self {
    case .createZeroHashAccount:
      return "/v1/zerohash/accounts"
    case .getUser:
      return "/v1/user"
    case .getAccount:
      return "/v1/account/"
    case .getTransactions(let accountId, _, _, _):
      return "/v1/transactions/\(accountId)"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .createZeroHashAccount: return .POST
    case .getUser, .getAccount, .getTransactions: return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": self.productID,
      "Accept": "application/json",
      "Authorization": self.authorization
    ]
    switch self {
    case .createZeroHashAccount, .getAccount, .getTransactions:
      return base
    case .getUser(let deviceId):
      base["ld-device-id"] = deviceId
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .createZeroHashAccount:
      return nil
    case .getUser:
      return nil
    case .getAccount(let currencyType):
      return ["currencyType": currencyType]
    case .getTransactions(_, let currencyType, let limit, let offset):
      return [
        "currencyType": currencyType,
        "limit": String(limit),
        "offset": String(offset)
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .createZeroHashAccount, .getUser:
      return nil
    case .getAccount, .getTransactions:
      return .url
    }
  }
  
}
