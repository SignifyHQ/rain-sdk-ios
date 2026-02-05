import Foundation

public class RainMake3dsChallengeDecisionUseCase: RainMake3dsChallengeDecisionUseCaseProtocol {
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(approvalId: String, decision: String) async throws {
    try await repository.make3dsChallengeDecision(approvalId: approvalId, decision: decision)
  }
}
