import Foundation
import RewardDomain
import RewardData

  // MARK: - Cause

struct CauseModel: Hashable, Identifiable {
  let id: String
  let productId: String
  let name: String
  let logoUrl: URL?
  let rank: Int
}

// MARK: Codable
extension CauseModel: Codable {
  init?(rewardData: RewardCategoriesEntity) {
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
