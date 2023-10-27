import Foundation
  
public class NSGetBankRemainingAmountUseCase: NSGetBankRemainingAmountUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(sessionID: String, type: String) async throws -> [TransferLimitConfigEntity] {
    try await self.repository.getBankRemainingAmount(sessionID: sessionID, type: type)
  }
}
