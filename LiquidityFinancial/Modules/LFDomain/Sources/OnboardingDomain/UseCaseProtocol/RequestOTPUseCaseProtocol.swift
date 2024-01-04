import Foundation

public protocol RequestOTPUseCaseProtocol {
  func execute(isNewAuth: Bool, parameters: OTPParametersEntity) async throws -> OtpEntity
}
