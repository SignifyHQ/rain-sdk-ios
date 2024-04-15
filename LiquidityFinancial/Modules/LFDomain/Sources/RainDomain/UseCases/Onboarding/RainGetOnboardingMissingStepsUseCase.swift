import Foundation
  
public class RainGetOnboardingMissingStepsUseCase: RainGetOnboardingMissingStepsUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(repository: RainRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> RainOnboardingMissingStepsEntity {
    try await repository.getOnboardingMissingSteps()
  }
}
