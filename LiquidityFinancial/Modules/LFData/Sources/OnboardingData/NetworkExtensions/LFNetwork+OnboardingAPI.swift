import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: OnboardingAPIProtocol where R == OnboardingRoute {
  public func getOnboardingProcess() async throws -> APIOnboardingProcess {
    let result = try await request(OnboardingRoute.getOnboardingProcess, target: [String].self, decoder: .apiDecoder)
    return APIOnboardingProcess(processSteps: result)
  }
  
  public func login(phoneNumber: String, otpCode: String, lastID: String) async throws -> APIAccessTokens {
    let requestParams = LoginParameters(phoneNumber: phoneNumber, otpCode: otpCode, lastID: lastID)
    return try await request(
      OnboardingRoute.login(requestParams),
      target: APIAccessTokens.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func requestOTP(phoneNumber: String) async throws -> APIOtp {
    return try await request(
      OnboardingRoute.otp(OTPParameters(phoneNumber: phoneNumber)),
      target: APIOtp.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getOnboardingState(sessionId: String) async throws -> APIOnboardingState {
    return try await request(OnboardingRoute.onboardingState(sessionId: sessionId), target: APIOnboardingState.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func refreshToken(token: String) async throws -> Bool {
    let result = try await request(OnboardingRoute.refreshToken(token: token))
    return (result.httpResponse?.statusCode ?? 500).isSuccess
  }
}
