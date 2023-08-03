import Foundation
import AccountDomain

public struct APITransaction: Codable {
  public let id, accountId, title, description: String
  public let amount, currentBalance: Int
  public let type, status: String
  public let completedAt, createdAt: String?
  public let updatedAt: String?
}
