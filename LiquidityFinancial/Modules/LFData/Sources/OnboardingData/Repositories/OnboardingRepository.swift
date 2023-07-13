import Foundation
import OnboardingDomain

public class OnboardingRepository: OnboardingRepositoryProtocol {
  
  private let onboardingAPI: OnboardingAPIProtocol
  
  public init(onboardingAPI: OnboardingAPIProtocol) {
    self.onboardingAPI = onboardingAPI
  }
  
  public func login(phoneNumber: String, code: String) async throws -> OnboardingDomain.AccessTokens {
    return try await onboardingAPI.login(phoneNumber: phoneNumber, code: code)
  }
  
  public func requestOTP(phoneNumber: String) async throws -> OnboardingDomain.OtpEntity {
    return try await onboardingAPI.requestOTP(phoneNumber: phoneNumber)
  }
  
}

extension APIAccessTokens: AccessTokens {}

extension APIOtp: OtpEntity {}
