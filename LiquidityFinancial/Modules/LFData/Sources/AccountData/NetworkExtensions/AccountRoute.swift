import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import Factory

public enum AccountRoute {
  case createZeroHashAccount
  case getUser
  case getAccount(currencyType: String)
  case getAccountDetail(id: String)
  case getTransactions(accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int)
  case getTransactionDetail(accountId: String, transactionId: String)
  case logout
  case createWalletAddress(accountId: String, address: String, nickname: String)
  case updateWalletAddress(accountId: String, walletId: String, walletAddress: String, nickname: String)
  case getWalletAddresses(accountId: String)
  case deleteWalletAddresses(accountId: String, walletAddress: String)
  case getReferralCampaign
  case getTaxFile(accountId: String)
  case getTaxFileYear(accountId: String, year: String)
  case addToWaitList(body: WaitListParameter)
  case getUserRewards
  case getFeatureConfig
  case createSupportTicket(title: String?, description: String?, type: String)
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
    case .getAccountDetail(let id):
      return "/v1/account/\(id)"
    case .getTransactions(let accountId, _, _, _, _):
      return "/v1/transactions/\(accountId)"
    case let .getTransactionDetail(accountId, transactionId):
      return "/v1/transactions/\(accountId)/transactions/\(transactionId)"
    case .createWalletAddress(let accountId, _, _), .getWalletAddresses(let accountId):
      return "v1/accounts/\(accountId)/wallet-addresses"
    case let .updateWalletAddress(accountId, _, walletAddress, _):
      return "v1/accounts/\(accountId)/wallet-addresses/\(walletAddress)"
    case let .deleteWalletAddresses(accountId, walletAddress):
      return "v1/accounts/\(accountId)/wallet-addresses/\(walletAddress)"
    case .getReferralCampaign:
      return "/v1/app/referral-campaign"
    case .getTaxFile(accountId: let accountId):
      return "/v1/account/\(accountId)/tax-file"
    case .getTaxFileYear(accountId: let accountId, year: let year):
      return "/v1/account/\(accountId)/tax-file/\(year)"
    case .addToWaitList:
      return "v1/user/add-to-wait-list"
    case .getUserRewards:
      return "v1/user/reward-campaigns"
    case .getFeatureConfig:
      return "/v1/feature-config"
    case .createSupportTicket:
      return "/v1/support-tickets"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .createZeroHashAccount, .logout, .createWalletAddress, .addToWaitList, .createSupportTicket:
      return .POST
    case .getUser, .getAccount, .getTransactions, .getTransactionDetail, .getWalletAddresses, .getReferralCampaign, .getAccountDetail:
      return .GET
    case .updateWalletAddress:
      return .PATCH
    case .deleteWalletAddresses:
      return .DELETE
    case .getTaxFile, .getTaxFileYear, .getUserRewards, .getFeatureConfig:
      return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Authorization": self.needAuthorizationKey
    ]
    switch self {
    case .getTaxFileYear:
      base["Content-Type"] = "application/pdf"
      return base
    default:
      base["Accept"] = "application/json"
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .createZeroHashAccount, .getUser, .getTransactionDetail, .logout, .getWalletAddresses, .deleteWalletAddresses:
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
    case .getReferralCampaign, .getTaxFile, .getTaxFileYear, .getAccountDetail, .getUserRewards, .getFeatureConfig:
      return nil
    case .addToWaitList(body: let body):
      return body.encoded()
    case let .createSupportTicket(title, description, type):
      return [
        "title": title ?? .empty,
        "description": description ?? .empty,
        "type": type
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .createWalletAddress, .updateWalletAddress, .addToWaitList, .createSupportTicket:
      return .json
    case .createZeroHashAccount, .getUser, .logout, .getWalletAddresses, .deleteWalletAddresses, .getTaxFile, .getTaxFileYear, .getAccountDetail, .getUserRewards, .getFeatureConfig:
      return nil
    case .getAccount, .getTransactions, .getTransactionDetail, .getReferralCampaign:
      return .url
    }
  }
  
}
