import Foundation
  
public class RainGetOnboardingMissingStepsUseCase: RainGetOnboardingMissingStepsUseCaseProtocol {
  
  private let repository: RainOnboardingRepositoryProtocol
  
  public init(repository: RainOnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> RainOnboardingMissingStepsEntity {
    try await repository.getOnboardingMissingSteps()
  }
}
