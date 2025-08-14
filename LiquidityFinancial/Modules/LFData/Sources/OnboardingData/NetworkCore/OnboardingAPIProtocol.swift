import Foundation

// sourcery: AutoMockable
public protocol OnboardingAPIProtocol {
  func login(parameters: LoginParameters, appCheckToken: String, recaptchaToken: String) async throws -> APIAccessTokens
  func walletExtensionToken(appCheckToken: String, recaptchaToken: String) async throws -> APIAccessTokens
  func newLogin(parameters: LoginParameters) async throws -> APIAccessTokens
  func requestOTP(parameters: OTPParameters, appCheckToken: String, recaptchaToken: String) async throws -> APIOtp
  func checkAccountExisting(parameters: CheckAccountExistingParameters) async throws -> APIAccountExistingResponse
  func newRequestOTP(parameters: OTPParameters) async throws -> APIOtp
  func refreshToken(token: String) async throws -> Bool
  func getOnboardingProcess() async throws -> APIOnboardingProcess
  func getUnsupportedStates(parameters: UnsupportedStateParameters) async throws -> [APIUnsupportedState]
  func joinWaitlist(parameters: JoinWaitlistParameters) async throws
}
