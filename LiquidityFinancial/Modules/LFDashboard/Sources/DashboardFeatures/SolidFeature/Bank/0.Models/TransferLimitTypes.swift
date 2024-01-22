import Foundation
import LFLocalizable

public enum TransferPeriod: String {
  case unknown
  case day
  case week
  case month
  case allTime
  case perTransaction = "per_transaction"
  
  public init(from decoder: Decoder) throws {
    self = try TransferPeriod(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
  
  public var title: String {
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

public enum TransferType: String {
  case unknown
  case card
  case bank
  case spending
  case spendToCard = "other"
  case financialInstitutionsSpending = "financial_institutions_spending"
  
  public init(from decoder: Decoder) throws {
    self = try TransferType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
}

public enum TransactionLimitType: String {
  case unknown
  case deposit
  case withdraw
  
  public init(from decoder: Decoder) throws {
    self = try TransactionLimitType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
  
  public var title: String {
    switch self {
    case .deposit:
      return LFLocalizable.TransferLimit.Deposit.tabTitle
    case .withdraw:
      return LFLocalizable.TransferLimit.Withdraw.tabTitle
    default:
      return .empty
    }
  }
}
