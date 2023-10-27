import Foundation
  
public class NSGetCardRemainingAmountUseCase: NSGetCardRemainingAmountUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(sessionID: String, type: String) async throws -> [TransferLimitConfigEntity] {
    try await self.repository.getCardRemainingAmount(sessionID: sessionID, type: type)
  }
}
