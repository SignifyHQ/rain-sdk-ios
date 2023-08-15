import Foundation
import DataUtilities
import LFUtilities

public protocol AccountAPIProtocol {
  func createZeroHashAccount() async throws -> APIZeroHashAccount
  func getUser(deviceId: String) async throws -> APIUser
  func getAccount(currencyType: String) async throws -> [APIAccount]
  func getTransactions(accountId: String, currencyType: String, limit: Int, offset: Int) async throws -> APITransactionList
  func getTransactionDetail(accountId: String, transactionId: String) async throws -> APITransaction
}
