import Foundation
import DataUtilities
import LFNetwork

extension LFNetwork: OnboardingAPIProtocol where R == OnboardingRoute {
  public func getUser(deviceId: String) async throws -> APIUser {
    return try await request(OnboardingRoute.getUser(deviceId: deviceId), target: APIUser.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func createZeroHashAccount() async throws -> APIZeroHashAccount {
    return try await request(OnboardingRoute.createZeroHashAccount, target: APIZeroHashAccount.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }

  public func login(phoneNumber: String, code: String) async throws -> APIAccessTokens {
    return try await request(
      OnboardingRoute.login(LoginParameters(phoneNumber: phoneNumber, code: code, productName: APIConstants.productNameDefault)),
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
}
