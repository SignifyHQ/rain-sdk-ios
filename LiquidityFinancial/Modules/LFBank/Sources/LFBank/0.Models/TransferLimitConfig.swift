import Foundation
import AccountDomain
import NetSpendDomain
import LFLocalizable

public struct TransferLimitConfig {
  public let userId: String?
  public let productId: String?
  public let period: TransferPeriod?
  public let transferType: TransferType?
  public let priority: Int
  public let amount: Double
  public let transferredAmount: Double?
  public let type: TransactionType
}

// MARK: - Functions
public extension TransferLimitConfig {
  init(from entity: TransferLimitConfigEntity) {
    self.init(
      userId: entity.userId,
      productId: entity.productId,
      period: TransferPeriod(rawValue: entity.period ?? .empty),
      transferType: TransferType(rawValue: entity.transferType ?? .empty),
      priority: entity.priority,
      amount: entity.amount,
      transferredAmount: entity.transferredAmount,
      type: TransactionType(rawValue: entity.type) ?? .unknown
    )
  }
}

// MARK: - Nested Types
public extension TransferLimitConfig {
  enum TransferPeriod: String {
    case unknown
    case day
    case week
    case month
    
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
      default:
        return .empty
      }
    }
  }
  
  enum TransferType: String {
    case unknown
    case card
    case bank
    
    public init(from decoder: Decoder) throws {
      self = try TransferType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
  }
  
  enum TransactionType: String {
    case unknown
    case deposit
    case withdraw
    
    public init(from decoder: Decoder) throws {
      self = try TransactionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
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
}
