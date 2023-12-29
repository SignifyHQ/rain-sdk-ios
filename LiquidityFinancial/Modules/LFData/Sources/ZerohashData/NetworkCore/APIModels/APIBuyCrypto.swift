import Foundation
import Foundation
import ZerohashDomain

public struct APIBuyCrypto: Codable, BuyCryptoEntity {
  public var id, accountID, title, currency: String?
  public var description: String?
  public var amount, currentBalance, fee: Double?
  public var type, status, completedAt, createdAt: String?
  public var updatedAt: String?
}
