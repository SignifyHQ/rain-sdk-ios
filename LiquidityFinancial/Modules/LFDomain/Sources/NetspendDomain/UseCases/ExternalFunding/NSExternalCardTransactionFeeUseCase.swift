import Foundation
  
public class NSExternalCardTransactionFeeUseCase: NSExternalCardTransactionFeeUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(
    parameters: ExternalTransactionParametersEntity,
    type: ExternalTransactionTypeEntity,
    sessionId: String
  ) async throws -> ExternalCardFeeEntity {
    try await repository.externalCardTransactionFee(
      parameters: parameters,
      type: type,
      sessionId: sessionId
    )
  }
}
