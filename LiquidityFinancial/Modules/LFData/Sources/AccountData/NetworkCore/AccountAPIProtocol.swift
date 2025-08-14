import Foundation
import OnboardingData

// sourcery: AutoMockable
public protocol AccountAPIProtocol {
  func getUser() async throws -> APIUser
  func createPassword(password: String) async throws
  func changePassword(oldPassword: String, newPassword: String) async throws
  func resetPasswordRequest(phoneNumber: String) async throws
  func resetPasswordVerify(phoneNumber: String, code: String) async throws -> APIPasswordResetToken
  func resetPassword(phoneNumber: String, password: String, token: String) async throws
  func loginWithPassword(phoneNumber: String, password: String) async throws -> APIAccessTokens
  func verifyEmailRequest() async throws
  func verifyEmail(code: String) async throws
  func getAvailableRewardCurrencies() async throws -> APIAvailableRewardCurrencies
  func getSelectedRewardCurrency() async throws -> APIRewardCurrency
  func updateSelectedRewardCurrency(rewardCurrency: String) async throws -> APIRewardCurrency
  func getTransactions(parameters: APITransactionsParameters) async throws -> APITransactionList
  func getTransactionDetail(transactionId: String) async throws -> APITransaction
  func getTransactionDetailByHashID(transactionHash: String) async throws -> APITransaction
  func createPendingTransaction(body: APIPendingTransactionParameters) async throws -> APITransaction
  func logout() async throws -> Bool
  func createWalletAddresses(accountId: String, address: String, nickname: String) async throws -> APIWalletAddress
  func updateWalletAddresses(accountId: String, walletId: String, walletAddress: String, nickname: String) async throws -> APIWalletAddress
  func getWalletAddresses(accountId: String) async throws -> [APIWalletAddress]
  func deleteWalletAddresses(accountId: String, walletAddress: String) async throws -> APIDeleteWalletResponse
  func getReferralCampaign() async throws -> APIReferralCampaign
  func addToWaitList(body: WaitListParameter) async throws -> Bool
  func getUserRewards() async throws -> [APIUserRewards]
  func getFeatureConfig() async throws -> APIAccountFeatureConfig
  func createSupportTicket(title: String?, description: String?, type: String) async throws -> APISupportTicket
  func getSecretKey() async throws -> APISecretKey
  func enableMFA(code: String) async throws -> APIEnableMFA
  func disableMFA(code: String) async throws -> APIDisableMFA
  func applyPromocode(phoneNumber: String, promocode: String) async throws
  func shouldShowPopup(campaign: String) async throws -> APIShouldShowPopup
  func savePopupShown(campaign: String) async throws
}
