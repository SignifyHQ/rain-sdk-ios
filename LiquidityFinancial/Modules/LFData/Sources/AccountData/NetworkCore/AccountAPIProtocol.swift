import Foundation
import NetworkUtilities
import LFUtilities

public protocol AccountAPIProtocol {
  func createZeroHashAccount() async throws -> APIZeroHashAccount
  func getUser() async throws -> APIUser
  func getAccount(currencyType: String) async throws -> [APIAccount]
  func getAccountDetail(id: String) async throws -> APIAccount
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
  func getTaxFile(accountId: String) async throws -> [APITaxFile]
  func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL
  func addToWaitList(body: WaitListParameter) async throws -> Bool
  func getUserRewards() async throws -> [APIUserRewards]
  func getFeatureConfig() async throws -> APIAccountFeatureConfig
}
