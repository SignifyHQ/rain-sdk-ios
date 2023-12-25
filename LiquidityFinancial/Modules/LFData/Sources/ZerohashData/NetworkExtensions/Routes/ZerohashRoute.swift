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
  case sellCrypto(accountId: String, quoteId: String)
  case getSellQuote(accountId: String, amount: String?, quantity: String?)
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
    case .sellCrypto(accountId: let accountId, quoteId: _):
      return "/v1/zerohash/accounts/\(accountId)/sell"
    case .getSellQuote(accountId: let accountId, amount: _, quantity: _):
      return "/v1/zerohash/accounts/\(accountId)/sell/quote"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getOnboardingStep, .getTaxFile, .getTaxFileYear, .getSellQuote:
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
    case let .getSellQuote(_, amount, quantity):
      if let amount = amount, let quantity = quantity {
        return [
          "amount": amount,
          "quantity": quantity
        ]
      }
      return nil
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
    case .sellCrypto(_, let quoteId):
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
    case .getSellQuote:
      return .url
    default:
      return .json
    }
  }
  
}
