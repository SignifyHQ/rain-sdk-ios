import Foundation

// sourcery: AutoMockable
public protocol OnboardingRepositoryProtocol {
  func login(parameters: LoginParametersEntity) async throws -> AccessTokensEntity
  func newLogin(parameters: LoginParametersEntity) async throws -> AccessTokensEntity
  func requestOTP(parameters: OTPParametersEntity) async throws -> OtpEntity
  func newRequestOTP(parameters: OTPParametersEntity) async throws -> OtpEntity
  func getOnboardingProcess() async throws -> OnboardingProcess
}
