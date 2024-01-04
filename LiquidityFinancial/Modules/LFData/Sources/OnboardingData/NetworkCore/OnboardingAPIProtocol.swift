import Foundation

// sourcery: AutoMockable
public protocol OnboardingAPIProtocol {
  func login(parameters: LoginParameters) async throws -> APIAccessTokens
  func newLogin(parameters: LoginParameters) async throws -> APIAccessTokens
  func requestOTP(parameters: OTPParameters) async throws -> APIOtp
  func newRequestOTP(parameters: OTPParameters) async throws -> APIOtp
  func refreshToken(token: String) async throws -> Bool
  func getOnboardingProcess() async throws -> APIOnboardingProcess
}
