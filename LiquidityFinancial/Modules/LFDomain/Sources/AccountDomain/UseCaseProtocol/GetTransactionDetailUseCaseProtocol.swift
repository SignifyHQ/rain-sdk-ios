import Foundation

public protocol GetTransactionDetailUseCaseProtocol {
  func execute(transactionID: String) async throws -> TransactionEntity
  func execute(transactionHash: String) async throws -> TransactionEntity
}
