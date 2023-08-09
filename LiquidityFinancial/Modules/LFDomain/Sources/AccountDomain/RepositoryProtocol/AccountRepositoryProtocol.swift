import Foundation
import LFUtilities

public protocol AccountRepositoryProtocol {
  func createZeroHashAccount() async throws -> ZeroHashAccount
  func getUser(deviceId: String) async throws -> LFUser
  func getAccount(currencyType: String) async throws -> [LFAccount]
  func getTransactions(accountId: String, currencyType: String, limit: Int, offset: Int) async throws -> TransactionListEntity
}
