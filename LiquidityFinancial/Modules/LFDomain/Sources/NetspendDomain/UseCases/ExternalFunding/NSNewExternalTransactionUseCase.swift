import Foundation
  
public class NSNewExternalTransactionUseCase: NSNewExternalTransactionUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(
    parameters: ExternalTransactionParametersEntity,
    type: ExternalTransactionTypeEntity,
    sessionId: String
  ) async throws -> ExternalTransactionResponseEntity {
    try await self.repository.newExternalTransaction(
      parameters: parameters,
      type: type,
      sessionId: sessionId
    )
  }
}
