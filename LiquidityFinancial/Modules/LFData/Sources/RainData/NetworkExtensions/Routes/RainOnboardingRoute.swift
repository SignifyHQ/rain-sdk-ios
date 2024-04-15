import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum RainOnboardingRoute {
  case getOnboardingMissingSteps
  case createAccount(parameters: APIRainPersonParameters)
}

extension RainOnboardingRoute: LFRoute {
  public var path: String {
    switch self {
    case .getOnboardingMissingSteps:
      return "/v1/rain/onboarding/missing-steps"
    case .createAccount:
      return "/v1/rain/person/create-account"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getOnboardingMissingSteps: return .GET
    case .createAccount: return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "ld-device-id": LFUtilities.deviceId
    ]
    base["Authorization"] = self.needAuthorizationKey
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .getOnboardingMissingSteps:
      return nil
    case let .createAccount(parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getOnboardingMissingSteps:
      return nil
    case .createAccount:
      return .json
    }
  }
}
