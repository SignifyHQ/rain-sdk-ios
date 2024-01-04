import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum OnboardingRoute {
  case requestOtp(parameters: OTPParameters)
  case login(parameters: LoginParameters)
  case newRequestOTP(parameters: OTPParameters)
  case newLogin(parameters: LoginParameters)
  case refreshToken(token: String)
  case getOnboardingProcess
}

extension OnboardingRoute: LFRoute {

  public var path: String {
    switch self {
    case .requestOtp:
      return "/v1/password-less/otp/request"
    case .login:
      return "/v1/password-less/login"
    case .newRequestOTP:
      return "/v2/auth/otp/request"
    case .newLogin:
      return "/v2/auth/login"
    case .refreshToken:
      return "/v1/password-less/refresh-token"
    case .getOnboardingProcess:
      return "/v1/app/onboarding-progress"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .login, .requestOtp, .newRequestOTP, .newLogin, .refreshToken: return .POST
    case .getOnboardingProcess: return .GET
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
    case .requestOtp, .login, .newRequestOTP, .newLogin:
      base["ld-device-id"] = LFUtilities.deviceId
      return base
    case .getOnboardingProcess:
      base["Accept"] = "application/json"
      base["Authorization"] = self.needAuthorizationKey
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .requestOtp(otpParameters), let .newRequestOTP(otpParameters):
      return otpParameters.encoded()
    case let .login(loginParameters), let .newLogin(loginParameters):
      return loginParameters.encoded()
    case .refreshToken(let refreshToken):
      var body: [String: Any] {
        [
          "refreshToken": refreshToken
        ]
      }
      return body
    case .getOnboardingProcess:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .login, .requestOtp, .newRequestOTP, .newLogin, .refreshToken: return .json
    case .getOnboardingProcess: return nil
    }
  }
  
}
