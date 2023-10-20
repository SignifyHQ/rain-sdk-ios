import Foundation
  
public class NSOnboardingUseCase: NSOnboardingUseCaseProtocol {
  
  private let repository: NSOnboardingRepositoryProtocol
  
  public init(repository: NSOnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func getOnboardingStep(sessionID: String) async throws -> NSOnboardingStepEntity {
    try await repository.getOnboardingStep(sessionID: sessionID)
  }
}
