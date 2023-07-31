import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager

public enum OnboardingRoute {
  case otp(OTPParameters)
  case login(LoginParameters)
  case onboardingState(sessionId: String)
}

extension OnboardingRoute: LFRoute {
  
  public var authorization: String {
    let auth = AuthorizationManager()
    return auth.fetchToken()
  }
  
  public var path: String {
    switch self {
    case .otp:
      return "/v1/password-less/otp/request"
    case .login:
      return "/v1/password-less/login"
    case .onboardingState:
      return "/v1/app/onboarding-state"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .login, .otp: return .POST
    case .onboardingState: return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": APIConstants.productID
    ]
    switch self {
    case .otp, .login:
      return base
    case .onboardingState(let sessionId):
      base["Accept"] = "application/json"
      base["Authorization"] = authorization
      base["netspendSessionId"] = sessionId
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case .otp(let otpParameters):
      return otpParameters.encoded()
    case .login(let loginParameters):
      return loginParameters.encoded()
    case .onboardingState:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .login, .otp: return .json
    case .onboardingState: return nil
    }
  }
  
}
