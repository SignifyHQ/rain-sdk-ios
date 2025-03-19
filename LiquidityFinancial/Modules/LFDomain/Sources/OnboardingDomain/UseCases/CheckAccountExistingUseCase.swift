import Foundation

public class CheckAccountExistingUseCase: CheckAccountExistingUseCaseProtocol {
  
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: CheckAccountExistingParametersEntity) async throws -> AccountExistingEntity {
    try await repository.checkAccountExisting(parameters: parameters)
  }
}
