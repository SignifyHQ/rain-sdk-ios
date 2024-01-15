import Foundation
import RewardDomain

public struct APICauseSuggestionResponse: CauseSuggestionResponseEntity, Codable {
  public let id: String
  public let userId: String
  public let suggestion: String
  public let createdAt: String
  public let updatedAt: String
  public let deletedAt: String?
  
  public init(
    id: String,
    userId: String,
    suggestion: String,
    createdAt: String,
    updatedAt: String,
    deletedAt: String?
  ) {
    self.id = id
    self.userId = userId
    self.suggestion = suggestion
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.deletedAt = deletedAt
  }
}
