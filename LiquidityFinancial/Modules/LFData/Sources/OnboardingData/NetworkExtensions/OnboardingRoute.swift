import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum OnboardingRoute {
  case otp(OTPParameters)
  case login(LoginParameters)
  case onboardingState(sessionId: String)
  case refreshToken(token: String)
  case getOnboardingProcess
}

extension OnboardingRoute: LFRoute {

  public var path: String {
    switch self {
    case .otp:
      return "/v1/password-less/otp/request"
    case .login:
      return "/v1/password-less/login"
    case .onboardingState:
      return "/v1/app/onboarding-state"
    case .refreshToken:
      return "/v1/password-less/refresh-token"
    case .getOnboardingProcess:
      return "/v1/app/onboarding-progress"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .login, .otp, .refreshToken: return .POST
    case .onboardingState, .getOnboardingProcess: return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
    switch self {
    case .refreshToken:
      return base
    case .otp, .login:
      base["ld-device-id"] = LFUtilities.deviceId
      return base
    case .onboardingState(let sessionId):
      base["Accept"] = "application/json"
      base["Authorization"] = self.needAuthorizationKey
      base["netspendSessionId"] = sessionId
      return base
    case .getOnboardingProcess:
      base["Accept"] = "application/json"
      base["Authorization"] = self.needAuthorizationKey
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .otp(let otpParameters):
      return otpParameters.encoded()
    case .login(let loginParameters):
      return loginParameters.encoded()
    case .refreshToken(let refreshToken):
      var body: [String: Any] {
        [
          "refreshToken": refreshToken
        ]
      }
      return body
    case .onboardingState, .getOnboardingProcess:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .login, .otp, .refreshToken: return .json
    case .onboardingState, .getOnboardingProcess: return nil
    }
  }
  
}
