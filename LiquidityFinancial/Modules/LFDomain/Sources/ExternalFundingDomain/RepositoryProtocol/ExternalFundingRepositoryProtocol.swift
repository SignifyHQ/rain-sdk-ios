import Foundation

public protocol ExternalFundingRepositoryProtocol {
  func set(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardEntity
}
