import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import Factory

public enum AccountRoute {
  case createZeroHashAccount
  case getUser
  case getAccount(currencyType: String)
  case getTransactions(accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int)
  case getTransactionDetail(accountId: String, transactionId: String)
  case logout
  case createWalletAddress(accountId: String, address: String, nickname: String)
  case updateWalletAddress(accountId: String, walletId: String, walletAddress: String, nickname: String)
  case getWalletAddresses(accountId: String)
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
    case .getTransactions(let accountId, _, _, _, _):
      return "/v1/transactions/\(accountId)"
    case let .getTransactionDetail(accountId, transactionId):
      return "/v1/transactions/\(accountId)/transactions/\(transactionId)"
    case .createWalletAddress(let accountId, _, _), .getWalletAddresses(let accountId):
      return "v1/accounts/\(accountId)/wallet-addresses"
    case let .updateWalletAddress(accountId, _, walletAddress, _):
      return "v1/accounts/\(accountId)/wallet-addresses/\(walletAddress)"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .createZeroHashAccount, .logout, .createWalletAddress:
      return .POST
    case .getUser, .getAccount, .getTransactions, .getTransactionDetail, .getWalletAddresses:
      return .GET
    case .updateWalletAddress:
      return .PATCH
    }
  }
  
  public var httpHeaders: HttpHeaders {
    let base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Accept": "application/json",
      "Authorization": self.needAuthorizationKey
    ]
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .createZeroHashAccount, .getUser, .getTransactionDetail, .logout, .getWalletAddresses:
      return nil
    case .getAccount(let currencyType):
      return ["currencyType": currencyType]
    case .getTransactions(_, let currencyType, let transactionTypes, let limit, let offset):
      return [
        "currencyType": currencyType,
        "transactionTypes": transactionTypes,
        "limit": String(limit),
        "offset": String(offset)
      ]
    case .createWalletAddress(_, let address, let nickname):
      return [
        "nickname": nickname,
        "address": address
      ]
    case let .updateWalletAddress(_, walletId, _, nickname):
      return [
        "nickname": nickname,
        "walletId": walletId
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .createWalletAddress, .updateWalletAddress:
      return .json
    case .createZeroHashAccount, .getUser, .logout, .getWalletAddresses:
      return nil
    case .getAccount, .getTransactions, .getTransactionDetail:
      return .url
    }
  }
  
}
