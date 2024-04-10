import Foundation
import OnboardingDomain

// sourcery: AutoMockable
public protocol AccountRepositoryProtocol {
  func createZeroHashAccount() async throws -> ZeroHashAccount
  func getUser() async throws -> LFUser
  func createPassword(password: String) async throws
  func changePassword(oldPassword: String, newPassword: String) async throws
  func resetPasswordRequest(phoneNumber: String) async throws
  func resetPasswordVerify(phoneNumber: String, code: String) async throws -> PasswordResetTokenEntity
  func resetPassword(phoneNumber: String, password: String, token: String) async throws
  func loginWithPassword(phoneNumner: String, password: String) async throws -> AccessTokensEntity
  func verifyEmailRequest() async throws
  func verifyEmail(code: String) async throws
  func getAvailableRewardCurrrencies() async throws -> AvailableRewardCurrenciesEntity
  func getSelectedRewardCurrency() async throws -> RewardCurrencyEntity
  func updateSelectedRewardCurrency(rewardCurrency: String) async throws -> RewardCurrencyEntity
  func getTransactions(
    accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int
  ) async throws -> TransactionListEntity
  func getTransactionDetail(accountId: String, transactionId: String) async throws -> TransactionEntity
  func logout() async throws -> Bool
  func backupWallet(cipher: String, method: String) async throws
  func restoreWallet(method: String) async throws -> WalletRestoreEntitiy
  func createWalletAddresses(accountId: String, address: String, nickname: String) async throws -> WalletAddressEntity
  func updateWalletAddresses(accountId: String, walletId: String, walletAddress: String, nickname: String) async throws -> WalletAddressEntity
  func getWalletAddresses(accountId: String) async throws -> [WalletAddressEntity]
  func deleteWalletAddresses(accountId: String, walletAddress: String) async throws -> DeleteWalletEntity
  func getReferralCampaign() async throws -> ReferralCampaignEntity
  func addToWaitList(waitList: String) async throws -> Bool
  func getUserRewards() async throws -> [UserRewardsEntity]
  func getFeatureConfig() async throws -> AccountFeatureConfigEntity
  func createSupportTicket(title: String?, description: String?, type: String) async throws -> SupportTicketEntity
  func getSecretKey() async throws -> SecretKeyEntity
  func enableMFA(code: String) async throws -> EnableMFAEntity
  func disableMFA(code: String) async throws -> DisableMFAEntity
  func refreshPortalSessionToken() async throws -> PortalSessionTokenEntity
  func verifyAndUpdatePortalWalletAddress() async throws
}
