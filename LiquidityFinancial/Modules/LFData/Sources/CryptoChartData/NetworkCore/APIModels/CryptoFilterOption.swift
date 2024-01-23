import Foundation
import LFLocalizable
import LFUtilities

public enum CryptoFilterOption: String, CaseIterable {
  case live
  case day
  case week
  case month
  case year
  case all
}

extension CryptoFilterOption {
  public var interval: String {
    switch self {
    case .live:
      return "1m"
    case .day:
      return "1d"
    case .week:
      return "1w"
    case .month:
      return "1m"
    case .year:
      return "1y"
    case .all:
      return "all-time"
    }
  }
}

  // MARK: - Identifiable
extension CryptoFilterOption: Identifiable {
  public var id: String {
    rawValue
  }
}

  // MARK: - UI Helpers
extension CryptoFilterOption {
  public var title: String {
    switch self {
    case .live:
      return L10N.Common.CryptoChart.Filter.live
    case .day:
      return L10N.Common.CryptoChart.Filter.day
    case .week:
      return L10N.Common.CryptoChart.Filter.week
    case .month:
      return L10N.Common.CryptoChart.Filter.month
    case .year:
      return L10N.Common.CryptoChart.Filter.year
    case .all:
      return L10N.Common.CryptoChart.Filter.all
    }
  }
  
  public var datetimeFormat: LiquidityDateFormatter {
    switch self {
    case .live:
      return .periodSeparated
    case .day:
      return LiquidityDateFormatter.hour
    case .week:
      return .periodSeparated
    case .month:
      return .periodSeparated
    case .year:
      return .periodSeparated
    case .all:
      return .yearOnly
    }
  }
}
