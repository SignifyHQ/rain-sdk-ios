import Foundation

public class RequestOTPUseCase: RequestOTPUseCaseProtocol {
  
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(phoneNumber: String) async throws -> OtpEntity {
    return try await repository.requestOTP(phoneNumber: phoneNumber)
  }
  
}
