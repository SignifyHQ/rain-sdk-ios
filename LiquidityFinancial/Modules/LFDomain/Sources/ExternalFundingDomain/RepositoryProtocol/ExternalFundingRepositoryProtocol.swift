import Foundation

public protocol ExternalFundingRepositoryProtocol {
  func set(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardEntity
  func getPinWheelToken(sessionID: String) async throws -> PinWheelTokenEntity
  func getACHInfo(sessionID: String) async throws -> ACHInfoEntity
}
