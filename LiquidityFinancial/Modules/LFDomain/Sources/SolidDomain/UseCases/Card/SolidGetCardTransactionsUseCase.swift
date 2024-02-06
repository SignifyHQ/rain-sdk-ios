import Foundation
import AccountDomain

public class SolidGetCardTransactionsUseCase: SolidGetCardTransactionsUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: SolidCardTransactionParametersEntity) async throws -> TransactionListEntity {
    try await self.repository.getCardTransactions(parameters: parameters)
  }
}
