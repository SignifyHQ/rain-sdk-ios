import Foundation

public class OnboardingStateUseCase: OnboardingUseCaseProtocol {
  
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionId: String) async throws -> OnboardingStateEnity {
    return try await self.repository.onboardingState(sessionId: sessionId)
  }
  
}
