import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum RainRoute {
  case getOnboardingMissingSteps
  case getExternalVerificationLink
  case createAccount(parameters: APIRainPersonParameters)
  case getCollateralContract
  case getCreditBalance
}

extension RainRoute: LFRoute {
  public var path: String {
    switch self {
    case .getOnboardingMissingSteps:
      return "/v1/rain/onboarding/missing-steps"
    case .getExternalVerificationLink:
      return "/v1/rain/person/application-external-verification-link"
    case .createAccount:
      return "/v1/rain/person/create-account"
    case .getCollateralContract:
      return "/v1/rain/person/collateral-contract"
    case .getCreditBalance:
      return "/v1/rain/person/credit-balances"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getOnboardingMissingSteps,
        .getExternalVerificationLink,
        .getCollateralContract,
        .getCreditBalance:
      return .GET
    case .createAccount:
      return .POST
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
    case .getOnboardingMissingSteps,
        .getExternalVerificationLink,
        .getCollateralContract,
        .getCreditBalance:
      return nil
    case let .createAccount(parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getOnboardingMissingSteps,
        .getExternalVerificationLink,
        .getCollateralContract,
        .getCreditBalance:
      return nil
    case .createAccount:
      return .json
    }
  }
}
