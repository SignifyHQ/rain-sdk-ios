import Foundation

// sourcery: AutoMockable
public protocol OnboardingAPIProtocol {
  func login(phoneNumber: String, otpCode: String, lastID: String) async throws -> APIAccessTokens
  func requestOTP(phoneNumber: String) async throws -> APIOtp
  func refreshToken(token: String) async throws -> Bool
  func getOnboardingProcess() async throws -> APIOnboardingProcess
}
