import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import Factory

public enum AccountRoute {
  case createZeroHashAccount
  case getUser
  case getAccount(currencyType: String)
  case getTransactions(accountId: String, currencyType: String, limit: Int, offset: Int)
  case getTransactionDetail(accountId: String, transactionId: String)
  case logout
}

extension AccountRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .logout:
      return "v1/user/logout"
    case .createZeroHashAccount:
      return "/v1/zerohash/accounts"
    case .getUser:
      return "/v1/user"
    case .getAccount:
      return "/v1/account/"
    case .getTransactions(let accountId, _, _, _):
      return "/v1/transactions/\(accountId)"
    case let .getTransactionDetail(accountId, transactionId):
      return "/v1/transactions/\(accountId)/transactions/\(transactionId)"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .createZeroHashAccount, .logout: return .POST
    case .getUser, .getAccount, .getTransactions, .getTransactionDetail: return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Accept": "application/json",
      "Authorization": self.needAuthorizationKey
    ]
    switch self {
    case .createZeroHashAccount, .getAccount, .getTransactions, .getTransactionDetail, .logout, .getUser:
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .createZeroHashAccount, .getUser, .getTransactionDetail, .logout:
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
    case .createZeroHashAccount, .getUser, .logout:
      return nil
    case .getAccount, .getTransactions, .getTransactionDetail:
      return .url
    }
  }
  
}
