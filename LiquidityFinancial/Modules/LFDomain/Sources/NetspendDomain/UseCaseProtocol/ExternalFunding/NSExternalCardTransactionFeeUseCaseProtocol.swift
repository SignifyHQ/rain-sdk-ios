import Foundation

public protocol NSExternalCardTransactionFeeUseCaseProtocol {
  func execute(
    parameters: ExternalTransactionParametersEntity,
    type: ExternalTransactionTypeEntity,
    sessionId: String
  ) async throws -> ExternalCardFeeEntity
}
