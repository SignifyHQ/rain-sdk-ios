import AuthorizationManager
import CoreNetwork
import Factory
import Foundation
import LFUtilities
import NetworkUtilities

public enum AccountRoute {
  case getUser
  case createPassword(password: String)
  case changePassword(oldPassword: String, newPassword: String)
  case resetPasswordRequest(phoneNumber: String)
  case resetPasswordVerify(phoneNumber: String, code: String)
  case resetPassword(phoneNumber: String, password: String, token: String)
  case loginWithPassword(phoneNumber: String, password: String)
  case verifyEmailRequest
  case verifyEmail(code: String)
  case getAvailableRewardCurrencies
  case getSelectedRewardCurrency
  case updateSelectedRewardCurrency(rewardCurrency: String)
  case getTransactions(parameters: APITransactionsParameters)
  case getTransactionDetail(transactionId: String)
  case getTransactionByHashID(transactionHash: String)
  case createPendingTransaction(body: APIPendingTransactionParameters)
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
  case getSecretKey
  case enableMFA(code: String)
  case disableMFA(code: String)
  case promocode(phoneNumber: String, promocode: String)
  case shouldShowPopup(campaign: String)
  case savePopupShown(campaign: String)
}

extension AccountRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .logout:
      return "v1/user/logout"
    case .getUser:
      return "/v2/user"
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
    case .verifyEmailRequest:
      return "v1/user/request-verify-email"
    case .verifyEmail:
      return "v1/user/verify-email"
    case .getAvailableRewardCurrencies:
      return "/v1/user/available-reward-currencies"
    case .getSelectedRewardCurrency:
      return "/v1/user/selected-reward-currency"
    case .updateSelectedRewardCurrency:
      return "/v1/user/selected-reward-currency"
    case .getTransactions:
      return "/v2/transactions/list"
    case let .getTransactionDetail(transactionId):
      return "/v1/transactions/detail/\(transactionId)"
    case .getTransactionByHashID:
      return "/v1/transactions/by-transaction-hash"
    case .createPendingTransaction:
      return "/v1/transactions/create-crypto-transaction"
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
    case .getSecretKey:
      return "/v1/mfa/secret-key"
    case .enableMFA:
      return "/v1/mfa/enable"
    case .disableMFA:
      return "/v1/mfa/disable"
    case .promocode:
      return "/v1/user/promo-code"
    case .shouldShowPopup:
      return "/v1/user/popup-onboarding"
    case .savePopupShown:
      return "/v1/user/popup-onboarding/view"
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
        .verifyEmailRequest,
        .verifyEmail,
        .createPendingTransaction,
        .logout,
        .createWalletAddress,
        .addToWaitList,
        .createSupportTicket,
        .updateSelectedRewardCurrency,
        .enableMFA,
        .disableMFA,
        .promocode,
        .savePopupShown:
      return .POST
    case .getUser,
        .getTransactions,
        .getTransactionDetail,
        .getTransactionByHashID,
        .getWalletAddresses,
        .getReferralCampaign,
        .getAvailableRewardCurrencies,
        .getSelectedRewardCurrency,
        .getSecretKey,
        .getUserRewards,
        .getFeatureConfig,
        .shouldShowPopup:
      return .GET
    case .updateWalletAddress:
      return .PATCH
    case .deleteWalletAddresses:
      return .DELETE
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
    case .getUser,
        .verifyEmailRequest,
        .getTransactionDetail,
        .logout,
        .getWalletAddresses,
        .deleteWalletAddresses,
        .getAvailableRewardCurrencies,
        .getSelectedRewardCurrency,
        .getReferralCampaign,
        .getUserRewards,
        .getFeatureConfig,
        .getSecretKey:
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
    case .verifyEmail(let code):
      return [
        "code": code
      ]
    case .getTransactions(let parameters):
      return parameters.encoded()
    case .createPendingTransaction(let body):
      return body.encoded()
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
    case let .enableMFA(code):
      return [
        "code": code
      ]
    case let .disableMFA(code):
      return [
        "code": code
      ]
    case let .getTransactionByHashID(transactionHash):
      return [
        "transactionHash": transactionHash
      ]
    case let .promocode(phoneNumber, promocode):
      return [
        "productId": NetworkUtilities.productID,
        "phone": phoneNumber,
        "promoCode": promocode
      ]
    case let .shouldShowPopup(campaign):
      return [
        "token": campaign
      ]
    case let .savePopupShown(campaign):
      return [
        "token": campaign
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
        .verifyEmail,
        .createWalletAddress,
        .updateWalletAddress,
        .addToWaitList,
        .createPendingTransaction,
        .createSupportTicket,
        .updateSelectedRewardCurrency,
        .enableMFA,
        .disableMFA,
        .promocode:
      return .json
    case .getAvailableRewardCurrencies,
        .getSelectedRewardCurrency,
        .getUser,
        .verifyEmailRequest,
        .logout,
        .getWalletAddresses,
        .deleteWalletAddresses,
        .getUserRewards,
        .getFeatureConfig,
        .getSecretKey:
      return nil
    case .getTransactions,
        .getTransactionDetail,
        .getTransactionByHashID,
        .getReferralCampaign,
        .shouldShowPopup,
        .savePopupShown:
      return .url
    }
  }
  
}
