import Foundation

// sourcery: AutoMockable
public protocol AccountAPIProtocol {
  func createZeroHashAccount() async throws -> APIZeroHashAccount
  func getUser() async throws -> APIUser
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
}
