import Foundation
  
public class SolidOnboardingUseCase: SolidOnboardingUseCaseProtocol {
  
  private let repository: SolidOnboardingRepositoryProtocol
  
  public init(repository: SolidOnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> SolidOnboardingStepEntity {
    try await repository.getOnboardingStep()
  }
}
