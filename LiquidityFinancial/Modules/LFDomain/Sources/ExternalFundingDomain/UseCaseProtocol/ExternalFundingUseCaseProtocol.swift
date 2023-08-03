import Foundation

public protocol ExternalFundingUseCaseProtocol {
  func set(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardResponseEntity
}
