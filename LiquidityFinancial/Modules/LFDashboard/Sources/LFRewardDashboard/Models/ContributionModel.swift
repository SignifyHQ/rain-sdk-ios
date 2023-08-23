import Foundation
import RewardDomain

public struct ContributionModel {
  public let id, title, fundraiserId, userId, userName: String?
  public let amount: Double?
  public let stickerUrl, status, createdAt: String?
  
  init(entity: ContributionEntity) {
    self.id = entity.id
    self.title = entity.title
    self.fundraiserId = entity.fundraiserId
    self.userId = entity.userId
    self.userName = entity.userName
    self.amount = entity.amount
    self.stickerUrl = entity.stickerUrl
    self.status = entity.status
    self.createdAt = entity.createdAt
  }
}

