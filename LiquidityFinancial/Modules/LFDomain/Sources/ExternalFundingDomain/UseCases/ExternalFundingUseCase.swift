import Foundation
  
public class ExternalFundingUseCase: ExternalFundingUseCaseProtocol {
  private let repository: ExternalFundingRepositoryProtocol
  
  public init(repository: ExternalFundingRepositoryProtocol) {
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
}
