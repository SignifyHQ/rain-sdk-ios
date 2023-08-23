import Foundation
import RewardDomain

public struct APIContributionList: ContributionListEntity {
  public let total: Int
  public let data: [ContributionEntity]
}

public struct APIContribution: ContributionEntity, Codable {
  public let id, title, fundraiserId, userId, userName: String?
  public let amount: Double?
  public let stickerUrl, status, createdAt: String?
}
