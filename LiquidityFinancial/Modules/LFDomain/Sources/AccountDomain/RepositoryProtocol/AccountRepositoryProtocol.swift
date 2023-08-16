import Foundation
import LFUtilities

public protocol AccountRepositoryProtocol {
  func createZeroHashAccount() async throws -> ZeroHashAccount
  func getUser() async throws -> LFUser
  func getAccount(currencyType: String) async throws -> [LFAccount]
  func getTransactions(accountId: String, currencyType: String, limit: Int, offset: Int) async throws -> TransactionListEntity
  func getTransactionDetail(accountId: String, transactionId: String) async throws -> TransactionEntity
  func logout() async throws -> Bool
}
