import Foundation
import NetspendDomain

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
