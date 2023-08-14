import Foundation
  
public class NSExternalFundingUseCase: NSExternalFundingUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func set(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardEntity {
    try await repository.set(request: request, sessionID: sessionID)
  }
  
  public func getPinWheelToken(sessionID: String) async throws -> PinWheelTokenEntity {
    try await repository.getPinWheelToken(sessionID: sessionID)
  }
  
  public func getACHInfo(sessionID: String) async throws -> ACHInfoEntity {
    try await repository.getACHInfo(sessionID: sessionID)
  }
  
  public func getLinkedAccount(sessionId: String) async throws -> any LinkedSourcesEntity {
    try await repository.getLinkedAccount(sessionId: sessionId)
  }
  
  public func deleteLinkedAccount(sessionId: String, sourceId: String, sourceType: String) async throws -> UnlinkBankEntity {
    try await repository.deleteLinkedAccount(sessionId: sessionId, sourceId: sourceId, sourceType: sourceType)
  }
}
