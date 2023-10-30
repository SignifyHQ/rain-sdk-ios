import Foundation
  
public class SolidCreateExternalTransactionUseCase: SolidCreateExternalTransactionUseCaseProtocol {
  
  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double) async throws -> SolidExternalTransactionResponseEntity {
    try await repository.newTransaction(type: type, accountId: accountId, contactId: contactId, amount: amount)
  }
  
}
