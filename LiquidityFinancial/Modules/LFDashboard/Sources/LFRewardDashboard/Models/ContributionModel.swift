import Foundation
import RewardDomain
import LFRewards

public struct ContributionModel: Identifiable, Equatable {
  public let id: String
  public let title, fundraiserId, userId, userName: String?
  public let amount: Double?
  public let stickerUrl, status, createdAt: String?
  
  public init(entity: ContributionEntity) {
    self.id = entity.id ?? UUID().uuidString
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

extension RewardTransactionRowModel {
  init(contribution: ContributionModel) {
    self.init(
      id: contribution.id,
      fundraiserId: contribution.fundraiserId,
      donationId: nil,
      userId: contribution.userId,
      userName: contribution.userName,
      amount: contribution.amount,
      createdAt: contribution.createdAt
    )
  }
}
