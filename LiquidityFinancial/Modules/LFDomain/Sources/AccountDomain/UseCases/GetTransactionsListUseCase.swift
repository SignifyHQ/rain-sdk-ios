import Foundation

public final class GetTransactionsListUseCase: GetTransactionsListUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: TransactionsParametersEntity) async throws -> TransactionListEntity {
    try await repository.getTransactions(parameters: parameters)
  }
}
