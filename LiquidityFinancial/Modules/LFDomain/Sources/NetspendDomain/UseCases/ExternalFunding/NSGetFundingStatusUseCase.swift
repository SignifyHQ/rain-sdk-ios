import Foundation
  
public class NSGetFundingStatusUseCase: NSGetFundingStatusUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(sessionID: String) async throws -> any ExternalFundingsatusEntity {
    try await self.repository.getFundingStatus(sessionID: sessionID)
  }
}
