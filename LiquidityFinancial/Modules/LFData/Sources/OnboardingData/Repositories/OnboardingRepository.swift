import AuthorizationManager
import Foundation
import OnboardingDomain

public class OnboardingRepository: OnboardingRepositoryProtocol {
  private let onboardingAPI: OnboardingAPIProtocol
  private let auth: AuthorizationManagerProtocol
  
  public init(onboardingAPI: OnboardingAPIProtocol, auth: AuthorizationManagerProtocol) {
    self.onboardingAPI = onboardingAPI
    self.auth = auth
  }
  
  public func login(parameters: LoginParametersEntity) async throws -> AccessTokensEntity {
    let appCheckToken = try await auth.getAppCheckToken()
    let reCaptchaToken = try await auth.getReCaptchaToken(for: .login)
    
    let requestParameters = LoginParameters(
      phoneNumber: parameters.phoneNumber,
      email: parameters.email,
      otpCode: parameters.code,
      lastID: parameters.lastXId,
      verification: parameters.verificationEntity as? Verification
    )
    
    let accessTokens = try await onboardingAPI.login(
      parameters: requestParameters,
      appCheckToken: appCheckToken,
      recaptchaToken: reCaptchaToken
    )
    
    auth.refreshWith(apiToken: accessTokens)
    auth.savePortalSessionToken(token: accessTokens.portalSessionToken)
    
//    let walletExtensionTokens = try await onboardingAPI.walletExtensionToken(
//      appCheckToken: appCheckToken,
//      recaptchaToken: reCaptchaToken
//    )
//    
//    auth.saveWalletExtenstionTokens(apiToken: walletExtensionTokens)
    
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
    let appCheckToken = try await auth.getAppCheckToken()
    let reCaptchaToken = try await auth.getReCaptchaToken(for: .custom("otp_request"))
    
    let requestParameters = OTPParameters(
      phoneNumber: parameters.phoneNumber,
      email: parameters.email
    )
    
    return try await onboardingAPI.requestOTP(
      parameters: requestParameters,
      appCheckToken: appCheckToken,
      recaptchaToken: reCaptchaToken
    )
  }
  
  public func checkAccountExisting(parameters: CheckAccountExistingParametersEntity) async throws -> AccountExistingEntity {
    let requestParameters = CheckAccountExistingParameters(
      phoneNumber: parameters.phone,
      email: parameters.email
    )
    
    return try await onboardingAPI.checkAccountExisting(parameters: requestParameters)
  }
  
  public func newRequestOTP(parameters: OTPParametersEntity) async throws -> OtpEntity {
    let requestParameters = OTPParameters(phoneNumber: parameters.phoneNumber)
    
    return try await onboardingAPI.newRequestOTP(parameters: requestParameters)
  }
  
  public func getOnboardingProcess() async throws -> OnboardingProcess {
    return try await onboardingAPI.getOnboardingProcess()
  }
  
  public func getUnsupportedStates(parameters: UnsupportedStateParametersEntity) async throws -> [UnsupportedStateEntity] {
    let requestParameters = UnsupportedStateParameters(countryCode: parameters.countryCode)
    
    return try await onboardingAPI.getUnsupportedStates(parameters: requestParameters)
  }
  
  public func joinWaitlist(parameters: JoinWaitlistParametersEntity) async throws {
    let requestParameters = JoinWaitlistParameters(
      countryCode: parameters.countryCode,
      stateCode: parameters.stateCode,
      firstName: parameters.firstName,
      lastName: parameters.lastName,
      email: parameters.email
    )
    
    return try await onboardingAPI.joinWaitlist(parameters: requestParameters)
  }
}

extension APIAccessTokens: AccessTokensEntity {}

extension APIOtp: OtpEntity {}

extension APIOnboardingProcess: OnboardingProcess {}
