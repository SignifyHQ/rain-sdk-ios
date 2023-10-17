import Foundation

// sourcery: AutoMockable
public protocol OnboardingRepositoryProtocol {
  func login(phoneNumber: String, otpCode: String, lastID: String) async throws -> AccessTokensEntity
  func requestOTP(phoneNumber: String) async throws -> OtpEntity
  func onboardingState(sessionId: String) async throws -> OnboardingStateEnity
  func getOnboardingProcess() async throws -> OnboardingProcess
}
