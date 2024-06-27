import Foundation

public protocol CreatePendingTransactionUseCaseProtocol {
  func execute(body: PendingTransactionParametersEntity) async throws -> TransactionEntity
}
