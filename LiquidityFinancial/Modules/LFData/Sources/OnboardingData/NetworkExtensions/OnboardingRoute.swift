import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum OnboardingRoute {
  case requestOtp(parameters: OTPParameters, appCheckToken: String, recaptchaToken: String)
  case checkAccountExisting(parameters: CheckAccountExistingParameters)
  case login(parameters: LoginParameters, appCheckToken: String, recaptchaToken: String)
  case newRequestOTP(parameters: OTPParameters)
  case newLogin(parameters: LoginParameters)
  case refreshToken(token: String)
  case getOnboardingProcess
  case getUnsupportedStates(parameters: UnsupportedStateParameters)
  case joinWailist(parameters: JoinWaitlistParameters)
}

extension OnboardingRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .requestOtp:
      return "/v2/password-less/otp/request"
    case .checkAccountExisting:
      return "/v1/auth/exists"
    case .login:
      return "/v2/password-less/login"
    case .newRequestOTP:
      return "/v2/auth/otp/request"
    case .newLogin:
      return "/v2/auth/login"
    case .refreshToken:
      return "/v1/password-less/refresh-token"
    case .getOnboardingProcess:
      return "/v1/app/onboarding-progress"
    case .getUnsupportedStates:
      return "/v1/blocked-states"
    case .joinWailist:
      return "/v1/blocked-states/subscribe"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .login, .requestOtp, .checkAccountExisting, .newRequestOTP, .newLogin, .refreshToken, .joinWailist: return .POST
    case .getOnboardingProcess, .getUnsupportedStates: return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
    
    switch self {
    case .refreshToken:
      break
    case .checkAccountExisting, .newRequestOTP, .newLogin:
      base["ld-device-id"] = LFUtilities.deviceId
    case .login(_, let appCheckToken, let recaptchaToken), .requestOtp(_, let appCheckToken, let recaptchaToken):
      base["ld-device-id"] = LFUtilities.deviceId
      base["x-app-check-token"] = appCheckToken
      base["x-recaptcha-token"] = recaptchaToken
      base["x-platform"] = "IOS"
    case .getOnboardingProcess, .getUnsupportedStates, .joinWailist:
      base["Accept"] = "application/json"
      base["Authorization"] = self.needAuthorizationKey
    }
    
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .requestOtp(otpParameters, _, _), let .newRequestOTP(otpParameters):
      return otpParameters.encoded()
    case let .checkAccountExisting(parameters):
      return parameters.encoded()
    case let .login(loginParameters, _, _), let .newLogin(loginParameters):
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
    case let .getUnsupportedStates(unsupportedParameters):
      return unsupportedParameters.encoded()
    case let .joinWailist(joinWaitlistParameters):
      return joinWaitlistParameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .login, .requestOtp, .newRequestOTP, .newLogin, .refreshToken, .joinWailist: return .json
    case .checkAccountExisting, .getUnsupportedStates: return .url
    case .getOnboardingProcess: return nil
    }
  }
  
}
