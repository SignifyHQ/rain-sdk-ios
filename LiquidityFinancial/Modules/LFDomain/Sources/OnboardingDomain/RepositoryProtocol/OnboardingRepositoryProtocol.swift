import Foundation

public protocol OnboardingRepositoryProtocol {
  func login(phoneNumber: String, otpCode: String, lastID: String) async throws -> AccessTokens
  func requestOTP(phoneNumber: String) async throws -> OtpEntity
  func getOnboardingState(sessionId: String) async throws -> OnboardingState
}
