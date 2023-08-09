import Foundation
import AccountDomain

public struct APITransactionList: TransactionListEntity {
  public var total: Int
  public var data: [TransactionEntity]
}

public struct APITransaction: TransactionEntity, Codable {
  public let id, accountId: String
  public let title, description: String?
  public let amount, currentBalance: Int?
  public let type, status: String?
  public let completedAt, createdAt: String?
  public let updatedAt: String?
}
