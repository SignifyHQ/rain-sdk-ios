import Foundation
  
public protocol NSNewExternalTransactionUseCaseProtocol {
  func execute(
    parameters: ExternalTransactionParametersEntity,
    type: ExternalTransactionTypeEntity,
    sessionId: String
  ) async throws -> ExternalTransactionResponseEntity
}
