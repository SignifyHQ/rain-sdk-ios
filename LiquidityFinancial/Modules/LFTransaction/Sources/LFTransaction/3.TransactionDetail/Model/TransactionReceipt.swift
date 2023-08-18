import Foundation

public struct TransactionReceipt {
  public var id: String
  public var accountId: String
  public var fee: Double?
  public var completedAt: String?
  
  init(id: String, accountId: String, fee: Double? = nil, completedAt: String? = nil) {
    self.id = id
    self.accountId = accountId
    self.fee = fee
    self.completedAt = completedAt
  }
}
