import Foundation
  
public class NSGetPinWheelTokenUseCase: NSGetPinWheelTokenUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(sessionID: String) async throws -> PinWheelTokenEntity {
    try await repository.getPinWheelToken(sessionID: sessionID)
  }
}
