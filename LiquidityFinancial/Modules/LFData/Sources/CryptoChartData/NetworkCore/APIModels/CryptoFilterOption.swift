import Foundation
import LFLocalizable

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
      return LFLocalizable.CryptoChart.Filter.live
    case .day:
      return LFLocalizable.CryptoChart.Filter.day
    case .week:
      return LFLocalizable.CryptoChart.Filter.week
    case .month:
      return LFLocalizable.CryptoChart.Filter.month
    case .year:
      return LFLocalizable.CryptoChart.Filter.year
    case .all:
      return LFLocalizable.CryptoChart.Filter.all
    }
  }
}
