import Foundation
import LFUtilities

protocol AccountUseCaseProtocol {
  func execute(accountId: String, currencyType: String, limit: Int, offset: Int) async throws -> TransactionListEntity
}
