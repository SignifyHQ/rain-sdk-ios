import Foundation

public final class CreatePendingTransactionUseCase: CreatePendingTransactionUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(body: PendingTransactionParametersEntity) async throws -> TransactionEntity {
    try await repository.createPendingTransaction(body: body)
  }
}
