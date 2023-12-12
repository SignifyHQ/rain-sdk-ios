import AuthorizationManager
import CoreNetwork
import Factory
import Foundation
import LFUtilities
import NetworkUtilities

public enum AccountRoute {
  case createZeroHashAccount
  case getUser
  case createPassword(password: String)
  case changePassword(oldPassword: String, newPassword: String)
  case resetPasswordRequest(phoneNumber: String)
  case resetPasswordVerify(phoneNumber: String, code: String)
  case resetPassword(phoneNumber: String, password: String, token: String)
  case loginWithPassword(phoneNumber: String, password: String)
  case getAvailableRewardCurrencies
  case getSelectedRewardCurrency
  case updateSelectedRewardCurrency(rewardCurrency: String)
  case getTransactions(accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int)
  case getTransactionDetail(accountId: String, transactionId: String)
  case logout
  case createWalletAddress(accountId: String, address: String, nickname: String)
  case updateWalletAddress(accountId: String, walletId: String, walletAddress: String, nickname: String)
  case getWalletAddresses(accountId: String)
  case deleteWalletAddresses(accountId: String, walletAddress: String)
  case getReferralCampaign
  case addToWaitList(body: WaitListParameter)
  case getUserRewards
  case getFeatureConfig
  case createSupportTicket(title: String?, description: String?, type: String)
  case getMigrationStatus
  case requestMigration
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
    case .createPassword:
      return "v1/user/create-password"
    case .resetPasswordRequest:
      return "/v1/auth/reset-password/otp/request"
    case .resetPasswordVerify:
      return "/v1/auth/reset-password/otp/verify"
    case .resetPassword:
      return "/v1/auth/reset-password"
    case .changePassword:
      return "v1/user/change-password"
    case .loginWithPassword:
      return "/v1/auth/login"
    case .getAvailableRewardCurrencies:
      return "/v1/user/available-reward-currencies"
    case .getSelectedRewardCurrency:
      return "/v1/user/selected-reward-currency"
    case .updateSelectedRewardCurrency:
      return "/v1/user/selected-reward-currency"
    case .getTransactions(let accountId, _, _, _, _):
      return "/v1/transactions/\(accountId)"
    case let .getTransactionDetail(_, transactionId):
      return "/v1/transactions/detail/\(transactionId)"
    case .createWalletAddress(let accountId, _, _), .getWalletAddresses(let accountId):
      return "v1/accounts/\(accountId)/wallet-addresses"
    case let .updateWalletAddress(accountId, _, walletAddress, _):
      return "v1/accounts/\(accountId)/wallet-addresses/\(walletAddress)"
    case let .deleteWalletAddresses(accountId, walletAddress):
      return "v1/accounts/\(accountId)/wallet-addresses/\(walletAddress)"
    case .getReferralCampaign:
      return "/v1/app/referral-campaign"
    case .addToWaitList:
      return "v1/user/add-to-wait-list"
    case .getUserRewards:
      return "v1/user/reward-campaigns"
    case .getFeatureConfig:
      return "/v1/feature-config"
    case .createSupportTicket:
      return "/v1/support-tickets"
    case .getMigrationStatus:
      return "/v1/user/migration-status"
    case .requestMigration:
      return "/v1/user/request-migration"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .createPassword,
        .changePassword,
        .resetPasswordRequest,
        .resetPasswordVerify,
        .resetPassword,
        .loginWithPassword,
        .createZeroHashAccount,
        .logout,
        .createWalletAddress,
        .addToWaitList,
        .createSupportTicket,
        .updateSelectedRewardCurrency,
        .requestMigration:
      return .POST
    case .getUser,
        .getTransactions,
        .getTransactionDetail,
        .getWalletAddresses,
        .getReferralCampaign,
        .getAvailableRewardCurrencies,
        .getSelectedRewardCurrency,
        .getMigrationStatus:
      return .GET
    case .updateWalletAddress:
      return .PATCH
    case .deleteWalletAddresses:
      return .DELETE
    case .getUserRewards,
        .getFeatureConfig:
      return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Authorization": self.needAuthorizationKey,
      "Accept": "application/json"
    ]
    
    if case .loginWithPassword = self {
      base["ld-device-id"] = LFUtilities.deviceId
    }
    
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .createZeroHashAccount,
        .getUser,
        .getTransactionDetail,
        .logout,
        .getWalletAddresses,
        .deleteWalletAddresses,
        .getAvailableRewardCurrencies,
        .getSelectedRewardCurrency,
        .getReferralCampaign,
        .getUserRewards,
        .getFeatureConfig,
        .getMigrationStatus,
        .requestMigration:
      return nil
    case .createPassword(let password):
      return [
        "request": [
          "password": password
        ]
      ]
    case .changePassword(let oldPassword, let newPassword):
      return [
        "request": [
          "oldPassword": oldPassword,
          "newPassword": newPassword
        ]
      ]
    case .resetPasswordRequest(let phoneNumber):
      return [
        "phoneNumber": phoneNumber
      ]
    case .resetPasswordVerify(let phoneNumber, let code):
      return [
        "phoneNumber": phoneNumber,
        "code": code
      ]
    case .resetPassword(let phoneNumber, let password, let token):
      return [
        "phone": phoneNumber,
        "token": token,
        "password": password
      ]
    case .loginWithPassword(let phoneNumber, let password):
      return [
        "phoneNumber": phoneNumber,
        "password": password
      ]
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
    case let .updateSelectedRewardCurrency(rewardCurrency):
        return [
          "request": [
            "rewardCurrency": rewardCurrency
          ]
        ]
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
    case .createPassword,
        .changePassword,
        .resetPasswordRequest,
        .resetPasswordVerify,
        .resetPassword,
        .loginWithPassword,
        .createWalletAddress,
        .updateWalletAddress,
        .addToWaitList,
        .createSupportTicket,
        .updateSelectedRewardCurrency:
      return .json
    case .createZeroHashAccount,
        .getAvailableRewardCurrencies,
        .getSelectedRewardCurrency,
        .getUser,
        .logout,
        .getWalletAddresses,
        .deleteWalletAddresses,
        .getUserRewards,
        .getFeatureConfig,
        .getMigrationStatus,
        .requestMigration:
      return nil
    case .getTransactions,
        .getTransactionDetail,
        .getReferralCampaign:
      return .url
    }
  }
  
}
