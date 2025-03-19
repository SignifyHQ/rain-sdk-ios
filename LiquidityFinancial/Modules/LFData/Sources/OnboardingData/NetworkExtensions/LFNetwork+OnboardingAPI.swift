import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: OnboardingAPIProtocol where R == OnboardingRoute {
  public func getOnboardingProcess() async throws -> APIOnboardingProcess {
    let result = try await request(OnboardingRoute.getOnboardingProcess, target: [String].self, decoder: .apiDecoder)
    return APIOnboardingProcess(processSteps: result)
  }
  
  public func login(parameters: LoginParameters) async throws -> APIAccessTokens {
    try await request(
      OnboardingRoute.login(parameters: parameters),
      target: APIAccessTokens.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func newLogin(parameters: LoginParameters) async throws -> APIAccessTokens {
    try await request(
      OnboardingRoute.newLogin(parameters: parameters),
      target: APIAccessTokens.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func requestOTP(parameters: OTPParameters) async throws -> APIOtp {
    return try await request(
      OnboardingRoute.requestOtp(parameters: parameters),
      target: APIOtp.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func checkAccountExisting(parameters: CheckAccountExistingParameters) async throws -> APIAccountExistingResponse {
    return try await request(
      OnboardingRoute.checkAccountExisting(parameters: parameters),
      target: APIAccountExistingResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func newRequestOTP(parameters: OTPParameters) async throws -> APIOtp {
    return try await request(
      OnboardingRoute.newRequestOTP(parameters: parameters),
      target: APIOtp.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func refreshToken(token: String) async throws -> Bool {
    let result = try await request(OnboardingRoute.refreshToken(token: token))
    return (result.httpResponse?.statusCode ?? 500).isSuccess
  }
}
