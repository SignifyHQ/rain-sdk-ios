import Foundation
import LFLocalizable

enum AccountLimitsType: String {
  case unknown
  case deposit
  case withdraw
  
  public var title: String {
    switch self {
    case .deposit:
      return L10N.Common.TransferLimit.Deposit.tabTitle
    case .withdraw:
      return L10N.Common.TransferLimit.Withdraw.tabTitle
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
      return L10N.Common.TransferLimit.Daily.title
    case .week:
      return L10N.Common.TransferLimit.Weekly.title
    case .month:
      return L10N.Common.TransferLimit.Monthly.title
    case .perTransaction:
      return L10N.Common.TransferLimit.PerTransaction.title
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
