import Foundation
import LFUtilities

public protocol AccountRepositoryProtocol {
  func createZeroHashAccount() async throws -> ZeroHashAccount
  func getUser() async throws -> LFUser
  func getAccount(currencyType: String) async throws -> [LFAccount]
  func getTransactions(
    accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int
  ) async throws -> TransactionListEntity
  func getTransactionDetail(accountId: String, transactionId: String) async throws -> TransactionEntity
  func logout() async throws -> Bool
  func createWalletAddresses(accountId: String, address: String, nickname: String) async throws -> WalletAddressEntity
  func updateWalletAddresses(accountId: String, walletId: String, walletAddress: String, nickname: String) async throws -> WalletAddressEntity
  func getWalletAddresses(accountId: String) async throws -> [WalletAddressEntity]
}
