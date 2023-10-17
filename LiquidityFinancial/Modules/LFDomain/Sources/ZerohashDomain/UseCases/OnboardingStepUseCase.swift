import Foundation

public class OnboardingStepUseCase: OnboardingStepUseCaseProtocol {

  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> ZHOnboardingStepEntity {
    return try await repository.getOnboardingStep()
  }
  
}
