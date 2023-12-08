import Foundation

// sourcery: AutoMockable
public protocol AccountRepositoryProtocol {
  func createZeroHashAccount() async throws -> ZeroHashAccount
  func getUser() async throws -> LFUser
  func createPassword(password: String) async throws
  func changePassword(oldPassword: String, newPassword: String) async throws
  func getAvailableRewardCurrrencies() async throws -> AvailableRewardCurrenciesEntity
  func getSelectedRewardCurrency() async throws -> RewardCurrencyEntity
  func updateSelectedRewardCurrency(rewardCurrency: String) async throws -> RewardCurrencyEntity
  func getTransactions(
    accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int
  ) async throws -> TransactionListEntity
  func getTransactionDetail(accountId: String, transactionId: String) async throws -> TransactionEntity
  func logout() async throws -> Bool
  func createWalletAddresses(accountId: String, address: String, nickname: String) async throws -> WalletAddressEntity
  func updateWalletAddresses(accountId: String, walletId: String, walletAddress: String, nickname: String) async throws -> WalletAddressEntity
  func getWalletAddresses(accountId: String) async throws -> [WalletAddressEntity]
  func deleteWalletAddresses(accountId: String, walletAddress: String) async throws -> DeleteWalletEntity
  func getReferralCampaign() async throws -> ReferralCampaignEntity
  func addToWaitList(waitList: String) async throws -> Bool
  func getUserRewards() async throws -> [UserRewardsEntity]
  func getFeatureConfig() async throws -> AccountFeatureConfigEntity
  func createSupportTicket(title: String?, description: String?, type: String) async throws -> SupportTicketEntity
  func getMigrationStatus() async throws -> MigrationStatusEntity
  func requestMigration() async throws -> MigrationStatusEntity
}
