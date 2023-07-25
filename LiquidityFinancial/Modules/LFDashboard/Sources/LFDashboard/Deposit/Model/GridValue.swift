import LFUtilities
import LFLocalizable

struct GridValue: Hashable {
  let type: Kind
  let currency: Currency

  var amount: Double {
    switch type {
    case let .fixed(amount):
      return amount
    case let .all(amount):
      return amount
    }
  }
  
  var display: String {
    switch type {
    case let .fixed(amount):
      switch currency {
      case .usd:
        return amount.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue)
      case .crypto:
        return LFLocalizable.GridValue.crypto(amount.formattedAmount())
      }
    case .all:
      return LFLocalizable.GridValue.all
    }
  }

  var formattedInput: String {
    amount.formattedAmount(maxFractionDigits: currency.maxFractionDigits)
  }
}

extension GridValue {
  static func fixed(amount: Double, currency: Currency) -> Self {
    .init(type: .fixed(amount: amount), currency: currency)
  }

  static func all(amount: Double, currency: Currency) -> Self {
    .init(type: .all(amount: amount), currency: currency)
  }
}

extension GridValue {
  enum Currency: Hashable {
    case usd
    case crypto

    fileprivate var maxFractionDigits: Int {
      switch self {
      case .usd:
        return Constants.CurrencyUnit.usd.maxFractionDigits
      case .crypto:
        return LFUtility.cryptoFractionDigits
      }
    }
  }

  enum Kind: Hashable {
    case fixed(amount: Double)
    case all(amount: Double)
  }
}
