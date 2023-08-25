import Foundation
import LFRewards
import RewardData
import RewardDomain

public struct CategoriesTrendingModel: Identifiable {
  public let id, name, description, stickerUrl: String?
  public let createdAt: String?
  public let goal: Int?
  public let currency: String?
  public let isFeatured, isLive: Bool?
  public let categories: [String]?
  
  public init(entity: CategoriesFundraisersEntity) {
    self.id = entity.id
    self.name = entity.name
    self.description = entity.description
    self.stickerUrl = entity.stickerUrl
    self.createdAt = entity.createdAt
    self.goal = entity.goal
    self.currency = entity.currency
    self.isFeatured = entity.isFeatured
    self.isLive = entity.isLive
    self.categories = entity.categories
  }
  
  var stickerURL: URL? {
    URL(string: stickerUrl ?? "")
  }
}
