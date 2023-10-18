import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import BankDomain

public enum NSOnboardingRoute {
  case getOnboardingStep(sessionID: String)
}

extension NSOnboardingRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .getOnboardingStep:
      return "/v1/netspend/onboarding/missing-steps"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getOnboardingStep: return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID
    ]
    base["Authorization"] = self.needAuthorizationKey
    switch self {
    case let .getOnboardingStep(sessionId):
      base["netspendSessionId"] = sessionId
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .getOnboardingStep:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getOnboardingStep:
      return nil
    }
  }
  
}
