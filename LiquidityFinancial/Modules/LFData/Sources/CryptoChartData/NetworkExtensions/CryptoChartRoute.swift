import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import Factory

public enum CryptoChartRoute {
  case getCMCSymbolHistories(symbol: String, period: String)
  case getPriceWebSocket(symbol: String)
}

extension CryptoChartRoute: LFRoute {
  
  public var path: String {
    switch self {
    case .getCMCSymbolHistories:
      return "/v1/crypto-graphs/cmc/histories"
    case .getPriceWebSocket(let symbol):
      return "/ws/cmc/\(symbol)/live"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getCMCSymbolHistories, .getPriceWebSocket:
      return .GET
    }
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
    case .getCMCSymbolHistories(let symbol, let period):
      return [
        "symbol": symbol,
        "period": period
      ]
    case .getPriceWebSocket:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .getCMCSymbolHistories:
      return .url
    case .getPriceWebSocket:
      return nil
    }
  }
  
}
