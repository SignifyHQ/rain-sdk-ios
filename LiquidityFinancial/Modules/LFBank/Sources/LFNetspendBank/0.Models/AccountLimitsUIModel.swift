import Foundation
import LFLocalizable

enum AccountLimitsType: String {
  case unknown
  case spending
  case deposit
  case withdraw
  
  public var title: String {
    switch self {
    case .deposit:
      return LFLocalizable.TransferLimit.Deposit.tabTitle
    case .withdraw:
      return LFLocalizable.TransferLimit.Withdraw.tabTitle
    case .spending:
      return LFLocalizable.TransferLimit.Spending.tabTitle
    default:
      return .empty
    }
  }
}

enum LimitsPeriodType: String {
  case unknown
  case day
  case week
  case month
  case perTransaction
  
  var title: String {
    switch self {
    case .day:
      return LFLocalizable.TransferLimit.Daily.title
    case .week:
      return LFLocalizable.TransferLimit.Weekly.title
    case .month:
      return LFLocalizable.TransferLimit.Monthly.title
    case .perTransaction:
      return LFLocalizable.TransferLimit.PerTransaction.title
    default:
      return .empty
    }
  }
}

extension Int {
  var toDouble: Double {
    Double(self)
  }
}
