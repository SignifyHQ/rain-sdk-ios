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
  
  public func login(parameters: LoginParametersEntity) async throws -> AccessTokensEntity {
    let requestParameters = LoginParameters(
      phoneNumber: parameters.phoneNumber,
      otpCode: parameters.code,
      lastID: parameters.lastXId,
      verification: parameters.verificationEntity as? Verification
    )
    
    let accessTokens = try await onboardingAPI.login(parameters: requestParameters)
    
    auth.refreshWith(apiToken: accessTokens)
    auth.savePortalSessionToken(token: accessTokens.portalSessionToken)
    
    return accessTokens
  }
  
  public func newLogin(parameters: LoginParametersEntity) async throws -> AccessTokensEntity {
    let requestParameters = LoginParameters(
      phoneNumber: parameters.phoneNumber,
      otpCode: parameters.code,
      lastID: parameters.lastXId,
      verification: parameters.verificationEntity as? Verification
    )
    
    let accessTokens = try await onboardingAPI.newLogin(parameters: requestParameters)
    
    auth.refreshWith(apiToken: accessTokens)
    auth.savePortalSessionToken(token: accessTokens.portalSessionToken)
    
    return accessTokens
  }
  
  public func requestOTP(parameters: OTPParametersEntity) async throws -> OtpEntity {
    let requestParameters = OTPParameters(phoneNumber: parameters.phoneNumber)
    
    return try await onboardingAPI.requestOTP(parameters: requestParameters)
  }
  
  public func newRequestOTP(parameters: OTPParametersEntity) async throws -> OtpEntity {
    let requestParameters = OTPParameters(phoneNumber: parameters.phoneNumber)
    
    return try await onboardingAPI.newRequestOTP(parameters: requestParameters)
  }
  
  public func getOnboardingProcess() async throws -> OnboardingProcess {
    return try await onboardingAPI.getOnboardingProcess()
  }
}

extension APIAccessTokens: AccessTokensEntity {}

extension APIOtp: OtpEntity {}

extension APIOnboardingProcess: OnboardingProcess {}
