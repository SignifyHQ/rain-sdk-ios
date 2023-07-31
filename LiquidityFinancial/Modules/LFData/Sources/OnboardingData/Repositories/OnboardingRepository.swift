import Foundation
import CommonDomain
import OnboardingDomain
import AuthorizationManager

public class OnboardingRepository: OnboardingRepositoryProtocol {
  private let onboardingAPI: OnboardingAPIProtocol
  private let auth: AuthorizationManagerProtocol
  
  public init(onboardingAPI: OnboardingAPIProtocol, auth: AuthorizationManagerProtocol) {
    self.onboardingAPI = onboardingAPI
    self.auth = auth
  }
  
  public func login(phoneNumber: String, code: String) async throws -> AccessTokens {
    let accessTokens = try await onboardingAPI.login(phoneNumber: phoneNumber, code: code)
    auth.refreshWith(apiToken: accessTokens)
    return accessTokens
  }
  
  public func requestOTP(phoneNumber: String) async throws -> OtpEntity {
    return try await onboardingAPI.requestOTP(phoneNumber: phoneNumber)
  }
  
  public func getOnboardingState(sessionId: String) async throws -> OnboardingState {
    return try await onboardingAPI.getOnboardingState(sessionId: sessionId)
  }
}

extension APIAccessTokens: AccessTokens {}

extension APIOtp: OtpEntity {}

extension APIOnboardingState: OnboardingState {}
