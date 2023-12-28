import Foundation
import OnboardingData

// sourcery: AutoMockable
public protocol AccountAPIProtocol {
  func createZeroHashAccount() async throws -> APIZeroHashAccount
  func getUser() async throws -> APIUser
  func createPassword(password: String) async throws
  func changePassword(oldPassword: String, newPassword: String) async throws
  func resetPasswordRequest(phoneNumber: String) async throws
  func resetPasswordVerify(phoneNumber: String, code: String) async throws -> APIPasswordResetToken
  func resetPassword(phoneNumber: String, password: String, token: String) async throws
  func loginWithPassword(phoneNumber: String, password: String) async throws -> APIAccessTokens
  func getAvailableRewardCurrencies() async throws -> APIAvailableRewardCurrencies
  func getSelectedRewardCurrency() async throws -> APIRewardCurrency
  func updateSelectedRewardCurrency(rewardCurrency: String) async throws -> APIRewardCurrency
  func getTransactions(
    accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int
  ) async throws -> APITransactionList
  func getTransactionDetail(accountId: String, transactionId: String) async throws -> APITransaction
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
  func getMigrationStatus() async throws -> APIMigrationStatus
  func requestMigration() async throws -> APIMigrationStatus
  func getSecretKey() async throws -> APISecretKey
  func enableMFA(code: String) async throws -> APIEnableMFA
  func disableMFA(code: String) async throws -> APIDisableMFA
}
