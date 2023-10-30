import Foundation
  
public class NSGetOnboardingStepUseCase: NSGetOnboardingStepUseCaseProtocol {
  
  private let repository: NSOnboardingRepositoryProtocol
  
  public init(repository: NSOnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionID: String) async throws -> NSOnboardingStepEntity {
    try await repository.getOnboardingStep(sessionID: sessionID)
  }
}
