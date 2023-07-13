import Foundation

public protocol OnboardingRepositoryProtocol {
  func login(phoneNumber: String, code: String) async throws -> AccessTokens
  func requestOTP(phoneNumber: String) async throws -> OtpEntity
}
