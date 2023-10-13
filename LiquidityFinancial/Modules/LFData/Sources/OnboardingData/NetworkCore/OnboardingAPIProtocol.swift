import Foundation

public protocol OnboardingAPIProtocol {
  func login(phoneNumber: String, otpCode: String, lastID: String) async throws -> APIAccessTokens
  func requestOTP(phoneNumber: String) async throws -> APIOtp
  func getOnboardingState(sessionId: String) async throws -> APIOnboardingState
  func refreshToken(token: String) async throws -> Bool
}
