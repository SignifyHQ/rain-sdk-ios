import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum RainRoute {
  case getOnboardingMissingSteps
  case getExternalVerificationLink
  case acceptTerms
  case getOccupationList
  case createAccount(parameters: APIRainPersonParameters)
  case getCollateralContract
  case getCreditBalance
  case getWithdrawalSignature(parameters: APIRainWithdrawalSignatureParameters)
}

extension RainRoute: LFRoute {
  public var path: String {
    switch self {
    case .getOnboardingMissingSteps:
      return "/v1/rain/onboarding/missing-steps"
    case .getExternalVerificationLink:
      return "/v1/rain/person/application-external-verification-link"
    case .acceptTerms:
      return "/v1/rain/onboarding/accept-terms"
    case .getOccupationList:
      return "/v1/rain/onboarding/occupations"
    case .createAccount:
      return "/v1/rain/person/create-account"
    case .getCollateralContract:
      return "/v1/rain/person/credit-contracts"
    case .getCreditBalance:
      return "/v1/rain/person/credit-balances"
    case .getWithdrawalSignature:
      return "/v1/rain/person/withdrawal/signature"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getOnboardingMissingSteps,
        .getExternalVerificationLink,
        .getCollateralContract,
        .getCreditBalance,
        .getOccupationList:
      return .GET
    case .acceptTerms, .createAccount, .getWithdrawalSignature:
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
        .acceptTerms,
        .getCollateralContract,
        .getCreditBalance,
        .getOccupationList:
      return nil
    case let .createAccount(parameters):
      return parameters.encoded()
    case let .getWithdrawalSignature(parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getOnboardingMissingSteps,
        .getExternalVerificationLink,
        .acceptTerms,
        .getCollateralContract,
        .getCreditBalance,
        .getOccupationList:
      return nil
    case .createAccount, .getWithdrawalSignature:
      return .json
    }
  }
}
