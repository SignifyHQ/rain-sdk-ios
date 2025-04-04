import Foundation

public class JoinWaitlistUseCase: JoinWaitlistUseCaseProtocol {
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: JoinWaitlistParametersEntity) async throws {
    try await repository.joinWaitlist(parameters: parameters)
  }
}
