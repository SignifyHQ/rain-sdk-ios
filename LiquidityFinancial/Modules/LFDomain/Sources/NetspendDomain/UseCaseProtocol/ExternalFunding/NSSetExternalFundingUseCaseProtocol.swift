import Foundation

public protocol NSSetExternalFundingUseCaseProtocol {
  func execute(
    request: ExternalCardParametersEntity,
    sessionID: String
  ) async throws -> ExternalCardEntity
}
