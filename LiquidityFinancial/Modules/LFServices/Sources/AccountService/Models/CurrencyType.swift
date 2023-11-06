import Foundation

public enum CurrencyType: String {
  
  case USD
  case DOGE
  case AVAX
  case ADA
  case USDC
  
}

public extension CurrencyType {
  
  var isFiat: Bool {
    switch self {
    case .USD:
      return true
    default:
      return false
    }
  }
  
}
