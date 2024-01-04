import Foundation

public class LoginUseCase: LoginUseCaseProtocol {
  
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(isNewAuth: Bool, parameters: LoginParametersEntity) async throws -> AccessTokensEntity {
    guard isNewAuth else {
      return try await repository.login(parameters: parameters)
    }
    return try await repository.newLogin(parameters: parameters)
  }
  
}
