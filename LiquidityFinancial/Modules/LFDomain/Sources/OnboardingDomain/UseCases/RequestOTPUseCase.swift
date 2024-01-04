import Foundation

public class RequestOTPUseCase: RequestOTPUseCaseProtocol {
  
  private let repository: OnboardingRepositoryProtocol
  
  public init(repository: OnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(isNewAuth: Bool, parameters: OTPParametersEntity) async throws -> OtpEntity {
    guard isNewAuth else {
      return try await repository.requestOTP(parameters: parameters)
    }
    return try await repository.newRequestOTP(parameters: parameters)
  }

}
