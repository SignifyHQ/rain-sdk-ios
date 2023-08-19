import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager

public enum ZerohashRoute {
  case sendCrypto(accountId: String, destinationAddress: String, amount: Double)
}

extension ZerohashRoute: LFRoute {

  public var path: String {
    switch self {
    case .sendCrypto(let accountId, _, _):
      return "v1/zerohash/account/\(accountId)/send"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .sendCrypto: return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    let base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Accept": "application/json",
      "Authorization": self.needAuthorizationKey
    ]
    switch self {
    case .sendCrypto:
      return base
    }
  }
  
  public var parameters: Parameters? {
    switch self {
    case let .sendCrypto(_, destinationAddress, amount):
      return [
        "destinationAddress": destinationAddress,
        "amount": amount
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .sendCrypto:
      return .json
    }
  }
  
}
