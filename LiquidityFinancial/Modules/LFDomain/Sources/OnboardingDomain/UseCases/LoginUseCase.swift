import Foundation

public class LoginUseCase: LoginUseCaseProtocol {
  
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(phoneNumber: String, code: String) async throws -> AccessTokens {
    return try await repository.login(phoneNumber: phoneNumber, code: code)
  }
  
}
