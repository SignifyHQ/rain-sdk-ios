import Foundation
import RewardDomain
import RewardData

  // MARK: - Cause

public struct CauseModel: Hashable, Identifiable {
  public let id: String
  public let productId: String
  public let name: String
  public let logoUrl: URL?
  public let rank: Int
}

// MARK: Codable
extension CauseModel: Codable {
  public init?(rewardData: RewardCategoriesEntity) {
    guard let id = rewardData.id,
          let name = rewardData.name,
          let logoUrl = rewardData.logoUrl,
          let rank = rewardData.rank,
          let productId = rewardData.productId else {
      return nil
    }
    self.id = id
    self.name = name
    self.logoUrl = URL(string: logoUrl)
    self.rank = rank
    self.productId = productId
  }
}
