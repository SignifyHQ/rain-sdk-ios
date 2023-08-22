import Foundation
import LFUtilities

protocol AccountUseCaseProtocol {
  func execute(
    accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int
  ) async throws -> TransactionListEntity
  func logout() async throws -> Bool
}
