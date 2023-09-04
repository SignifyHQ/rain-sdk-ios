import Foundation
import LFUtilities

public protocol AccountRepositoryProtocol {
  func createZeroHashAccount() async throws -> ZeroHashAccount
  func getUser() async throws -> LFUser
  func getAccount(currencyType: String) async throws -> [LFAccount]
  func getAccountDetail(id: String) async throws -> LFAccount
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
  func getTaxFile(accountId: String) async throws -> [any TaxFileEntity]
  func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL
  func addToWaitList(waitList: String) async throws -> Bool
}
