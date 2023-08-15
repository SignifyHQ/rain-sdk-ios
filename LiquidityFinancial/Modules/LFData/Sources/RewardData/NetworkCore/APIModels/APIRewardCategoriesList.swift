import Foundation
import RewardDomain

public struct APIRewardCategoriesList: RewardCategoriesListEntity {
  public var total: Int
  public var data: [RewardCategoriesEntity]
}

public struct APIRewardCategories: RewardCategoriesEntity, Codable {
  public let id, productId, name, description: String?
  public let logoUrl: String?
  public let rank: Int?
}
