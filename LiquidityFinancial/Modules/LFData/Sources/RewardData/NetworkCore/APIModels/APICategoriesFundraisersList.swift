import Foundation
import RewardDomain

public struct APICategoriesFundraisersList: CategoriesFundraisersListEntity {
  public var total: Int
  public var data: [CategoriesFundraisersEntity]
}

public struct APICategoriesFundraisers: CategoriesFundraisersEntity, Codable {
  public let id, name, description, stickerUrl: String?
  public let createdAt: String?
  public let goal: Int?
  public let currency: String?
  public let isFeatured, isLive: Bool?
  public let categories: [String]?
  
  public init(
    id: String? = nil,
    name: String? = nil,
    description: String? = nil,
    stickerUrl: String? = nil,
    createdAt: String? = nil,
    goal: Int? = nil,
    currency: String? = nil,
    isFeatured: Bool? = nil,
    isLive: Bool? = nil,
    categories: [String]? = nil
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.stickerUrl = stickerUrl
    self.createdAt = createdAt
    self.goal = goal
    self.currency = currency
    self.isFeatured = isFeatured
    self.isLive = isLive
    self.categories = categories
  }
}
