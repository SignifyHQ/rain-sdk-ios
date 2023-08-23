import Foundation
import RewardData
import RewardDomain

// MARK: - Fundraiser
public struct FundraiserModel: Hashable, Identifiable {
  public let id: String
  public let name: String
  public let description: String?
  public let goal: Int
  public let stickerUrlString: String
  public let currency: String
  public let isFeatured: Bool
  public let isLive: Bool
  public let categories: [String]
  
  public var stickerUrl: URL? {
    URL(string: stickerUrlString)
  }
  
  public init?(fundraiserData: CategoriesFundraisersEntity) {
    guard let id = fundraiserData.id,
          let name = fundraiserData.name,
          let description = fundraiserData.description,
          let goal = fundraiserData.goal,
          let stickerURL = fundraiserData.stickerUrl,
          let isFeatured = fundraiserData.isFeatured,
          let isLive = fundraiserData.isLive,
          let currency = fundraiserData.currency,
          let categories = fundraiserData.categories  else {
      return nil
    }
    self.id = id
    self.name = name
    self.description = description
    self.goal = goal
    self.stickerUrlString = stickerURL
    self.isFeatured = isFeatured
    self.isLive = isLive
    self.categories = categories
    self.currency = currency
  }
}

extension FundraiserModel {
    // The API is returning a dummy Fundraiser instead of returning null.
    // We need to manually ignore it so that the app doesn't show that a dummy fundraiser is selected.
  public var isValid: Bool {
    id != "00000000-0000-0000-0000-000000000000"
  }
}
