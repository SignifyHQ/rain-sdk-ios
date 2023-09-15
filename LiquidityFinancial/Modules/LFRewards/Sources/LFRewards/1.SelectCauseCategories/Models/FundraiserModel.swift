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
    guard let id = fundraiserData.id else {
      return nil
    }
    self.id = id
    self.name = fundraiserData.name ?? ""
    self.description = fundraiserData.description ?? ""
    self.goal = fundraiserData.goal ?? 0
    self.stickerUrlString = fundraiserData.stickerUrl ?? ""
    self.isFeatured = fundraiserData.isFeatured ?? false
    self.isLive = fundraiserData.isLive ?? false
    self.categories = fundraiserData.categories ?? []
    self.currency = fundraiserData.currency ?? "$"
  }
}

extension FundraiserModel {
    // The API is returning a dummy Fundraiser instead of returning null.
    // We need to manually ignore it so that the app doesn't show that a dummy fundraiser is selected.
  public var isValid: Bool {
    id != "00000000-0000-0000-0000-000000000000"
  }
}
