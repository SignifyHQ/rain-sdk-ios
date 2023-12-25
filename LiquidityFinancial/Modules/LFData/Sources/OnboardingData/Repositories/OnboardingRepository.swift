import Foundation
import OnboardingDomain
import AuthorizationManager

public class OnboardingRepository: OnboardingRepositoryProtocol {
  private let onboardingAPI: OnboardingAPIProtocol
  private let auth: AuthorizationManagerProtocol
  
  public init(onboardingAPI: OnboardingAPIProtocol, auth: AuthorizationManagerProtocol) {
    self.onboardingAPI = onboardingAPI
    self.auth = auth
  }
  
  public func login(phoneNumber: String, otpCode: String, lastID: String) async throws -> AccessTokensEntity {
    let accessTokens = try await onboardingAPI.login(phoneNumber: phoneNumber, otpCode: otpCode, lastID: lastID)
    auth.refreshWith(apiToken: accessTokens)
    return accessTokens
  }
  
  public func requestOTP(phoneNumber: String) async throws -> OtpEntity {
    return try await onboardingAPI.requestOTP(phoneNumber: phoneNumber)
  }
  
  public func getOnboardingProcess() async throws -> OnboardingProcess {
    return try await onboardingAPI.getOnboardingProcess()
  }
}

extension APIAccessTokens: AccessTokensEntity {}

extension APIOtp: OtpEntity {}

extension APIOnboardingProcess: OnboardingProcess {}
