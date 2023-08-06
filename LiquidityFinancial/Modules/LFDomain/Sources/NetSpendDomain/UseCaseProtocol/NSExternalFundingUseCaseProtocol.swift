import Foundation

public protocol NSExternalFundingUseCaseProtocol {
  func set(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardEntity
  func getPinWheelToken(sessionID: String) async throws -> PinWheelTokenEntity
  func getACHInfo(sessionID: String) async throws -> ACHInfoEntity
  func getLinkedAccount(sessionId: String) async throws -> any LinkedSourcesEntity
  func deleteLinkedAccount(sessionId: String, sourceId: String) async throws -> UnlinkBankEntity
}
