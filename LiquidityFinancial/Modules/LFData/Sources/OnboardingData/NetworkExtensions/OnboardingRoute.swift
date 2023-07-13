import Foundation
import LFNetwork
import DataUtilities

public enum OnboardingRoute {
  case otp(OTPParameters)
  case login(LoginParameters)
}

extension OnboardingRoute: LFRoute {
  public var baseURL: URL {
    APIConstants.baseURL
  }
  
  public var path: String {
    switch self {
    case .otp:
      return "/v1/password-less/otp/request"
    case .login:
      return "/v1/password-less/login"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .login, .otp: return HttpMethod.POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    ["Content-Type": "application/json"]
  }
  
  public var parameters: Parameters? {
    switch self {
    case .otp(let otpParameters):
      return otpParameters.encoded()
    case .login(let loginParameters):
      return loginParameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .login, .otp: return .json
    }
  }
  
}
