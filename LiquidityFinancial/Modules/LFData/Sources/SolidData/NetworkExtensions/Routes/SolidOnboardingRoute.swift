import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager

public enum SolidOnboardingRoute {
  case getOnboardingStep
  case createPerson(parameters: APISolidPersonParameters)
}

extension SolidOnboardingRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .getOnboardingStep:
      return "/v1/solid/onboarding/missing-steps"
    case .createPerson:
      return "/v1/solid/person/create-account"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getOnboardingStep: return .GET
    case .createPerson: return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
    base["Authorization"] = self.needAuthorizationKey
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .getOnboardingStep:
      return nil
    case .createPerson(parameters: let parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getOnboardingStep:
      return nil
    case .createPerson:
      return .json
    }
  }
  
}
