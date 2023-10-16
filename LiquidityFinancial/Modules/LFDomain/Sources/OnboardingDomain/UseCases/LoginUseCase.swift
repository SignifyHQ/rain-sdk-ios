import Foundation

public class LoginUseCase: LoginUseCaseProtocol {
  
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(phoneNumber: String, otpCode: String, lastID: String) async throws -> AccessTokensEntity {
    return try await repository.login(phoneNumber: phoneNumber, otpCode: otpCode, lastID: lastID)
  }
  
}
