import Foundation

public protocol GetTransactionDetailUseCaseProtocol {
  func execute(transactionID: String) async throws -> TransactionEntity
}
