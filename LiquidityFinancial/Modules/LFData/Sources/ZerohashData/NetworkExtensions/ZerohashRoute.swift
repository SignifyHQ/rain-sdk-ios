import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager

public enum ZerohashRoute {
  case sendCrypto(accountId: String, destinationAddress: String, amount: Double)
  case lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool)
  case executeQuote(accountId: String, quoteId: String)
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
    }
  }
  
  public var httpMethod: HttpMethod {
    return .POST
  }
  
  public var httpHeaders: HttpHeaders {
    let base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Accept": "application/json",
      "Authorization": self.needAuthorizationKey
    ]
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
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    return .json
  }
  
}
