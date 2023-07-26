import Foundation
import LFNetwork
import DataUtilities
import AuthorizationManager

public enum OnboardingRoute {
  case otp(OTPParameters)
  case login(LoginParameters)
  case onboardingState(sessionId: String)
  case createZeroHashAccount
  case getUser(deviceId: String)
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
    case .createZeroHashAccount:
      return "/v1/zerohash/accounts"
    case .getUser:
      return "/v1/user"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .login, .otp, .createZeroHashAccount: return .POST
    case .onboardingState, .getUser: return .GET
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
    case .createZeroHashAccount:
      base["Accept"] = "application/json"
      base["Authorization"] = authorization
      return base
    case .getUser(let deviceId):
      base["Accept"] = "application/json"
      base["Authorization"] = authorization
      base["ld-device-id"] = deviceId
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
    case .createZeroHashAccount:
      return nil
    case .getUser:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .login, .otp: return .json
    case .onboardingState, .createZeroHashAccount, .getUser: return nil
    }
  }
  
}
