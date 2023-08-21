import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: OnboardingAPIProtocol where R == OnboardingRoute {
  public func login(phoneNumber: String, code: String) async throws -> APIAccessTokens {
    return try await request(
      OnboardingRoute.login(LoginParameters(phoneNumber: phoneNumber, code: code)),
      target: APIAccessTokens.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func requestOTP(phoneNumber: String) async throws -> APIOtp {
    let result = try await request(OnboardingRoute.otp(OTPParameters(phoneNumber: phoneNumber)))
    return result.httpResponse?.statusCode == 200 ? APIOtp(success: true) : APIOtp(success: false)
  }
  
  public func getOnboardingState(sessionId: String) async throws -> APIOnboardingState {
    return try await request(OnboardingRoute.onboardingState(sessionId: sessionId), target: APIOnboardingState.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func refreshToken(token: String) async throws -> Bool {
    let result = try await request(OnboardingRoute.refreshToken(token: token))
    return (result.httpResponse?.statusCode ?? 500).isSuccess
  }
}
