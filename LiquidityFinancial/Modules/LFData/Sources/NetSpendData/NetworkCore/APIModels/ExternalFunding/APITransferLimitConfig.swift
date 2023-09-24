import Foundation
import NetSpendDomain

public struct APITransferLimitConfig: Codable {
  public let userId: String?
  public let productId: String?
  public let period: String?
  public let transferType: String?
  public let priority: Int
  public let amount: Double
  public let transferredAmount: Double?
  public let type: String
  public let createdAt: String?
  public let updatedAt: String?
}

extension APITransferLimitConfig: TransferLimitConfigEntity {}
