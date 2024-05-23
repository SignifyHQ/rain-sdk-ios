import Foundation

public final class GetTransactionDetailUseCase: GetTransactionDetailUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(transactionID: String) async throws -> TransactionEntity {
    try await repository.getTransactionDetail(transactionId: transactionID)
  }
  
  public func execute(transactionHash: String) async throws -> TransactionEntity {
    try await repository.getTransactionDetailByHashID(transactionHash: transactionHash)
  }
}
