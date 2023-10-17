import Foundation
import AccountDomain

public protocol ExecuteQuoteUseCaseProtocol {
  func execute(accountId: String, quoteId: String) async throws -> TransactionEntity
}
