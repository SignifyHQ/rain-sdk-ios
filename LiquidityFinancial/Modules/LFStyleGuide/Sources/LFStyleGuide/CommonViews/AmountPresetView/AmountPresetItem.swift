import LFUtilities
import LFLocalizable

public struct AmountPresetItem: Hashable {
  public let type: Kind
  public let currency: Currency
  
  public var amount: Double {
    switch type {
    case let .fixed(amount):
      return amount
    case let .all(amount):
      return amount
    }
  }
  
  public var display: String {
    switch type {
    case let .fixed(amount):
      switch currency {
      case .usd:
        return amount.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue)
      case .crypto(let coin):
        return "\(amount.formattedAmount()) \(coin)"
      }
    case .all:
      return L10N.Common.GridValue.all
    }
  }
  
  public var formattedInput: String {
    amount.formattedAmount(maxFractionDigits: currency.maxFractionDigits)
  }
}

public extension AmountPresetItem {
  static func fixed(amount: Double, currency: Currency) -> Self {
    .init(type: .fixed(amount: amount), currency: currency)
  }
  
  static func all(amount: Double, currency: Currency) -> Self {
    .init(type: .all(amount: amount), currency: currency)
  }
}

public extension AmountPresetItem {
  enum Currency: Hashable {
    case usd
    case crypto(coin: String)
    
    fileprivate var maxFractionDigits: Int {
      switch self {
      case .usd:
        return Constants.CurrencyUnit.usd.maxFractionDigits
      case .crypto:
        return LFUtilities.cryptoFractionDigits
      }
    }
  }
  
  enum Kind: Hashable {
    case fixed(amount: Double)
    case all(amount: Double)
  }
}
