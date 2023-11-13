import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager

public enum ZerohashRoute {
  case sendCrypto(accountId: String, destinationAddress: String, amount: Double)
  case lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool)
  case executeQuote(accountId: String, quoteId: String)
  case getOnboardingStep
  case getTaxFile(accountId: String)
  case getTaxFileYear(accountId: String, year: String)
}

extension ZerohashRoute: LFRoute {

  public var path: String {
    switch self {
    case .sendCrypto(let accountId, _, _):
      return "v1/zerohash/account/\(accountId)/send"
    case .lockedNetworkFee(let accountId, _, _, _):
      return "v1/zerohash/accounts/\(accountId)/withdrawal/locked-network-fee"
    case .executeQuote(let accountId, _):
      return "v1/zerohash/accounts/\(accountId)/withdrawal/execute"
    case .getOnboardingStep:
      return "/v1/zerohash/onboarding/missing-steps"
    case .getTaxFile(let accountId):
      return "/v1/zerohash/accounts/\(accountId)/tax-file"
    case .getTaxFileYear(let accountId, let year):
      return "/v1/zerohash/accounts/\(accountId)/tax-file/\(year)"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getOnboardingStep, .getTaxFile, .getTaxFileYear:
      return .GET
    default:
      return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Authorization": self.needAuthorizationKey
    ]
    switch self {
    case .getTaxFileYear:
      base["Content-Type"] = "application/pdf"
    default:
      base["Accept"] = "application/json"
    }
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .sendCrypto(_, destinationAddress, amount):
      return [
        "destinationAddress": destinationAddress,
        "amount": amount
      ]
    case .lockedNetworkFee(_, let destinationAddress, let amount, let maxAmount):
      return [
        "destinationAddress": destinationAddress,
        "amount": amount,
        "maxAmount": maxAmount
      ]
    case .executeQuote(_, let quoteId):
      return [
        "quoteId": quoteId
      ]
    case .getOnboardingStep, .getTaxFile, .getTaxFileYear:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getOnboardingStep,
        .getTaxFile,
        .getTaxFileYear:
      return nil
    default: return .json
    }
  }
  
}
