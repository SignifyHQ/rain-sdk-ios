import Foundation
import RewardDomain

// MARK: - Sticker

public struct Sticker: Hashable {
  let fundraiserID, stickerURL: String?
  let donationCount: Int?
  
  public init(entity: DonationStickerEntity) {
    self.fundraiserID = entity.fundraiserId
    self.stickerURL = entity.stickerUrl
    self.donationCount = entity.donationCount
  }
  
  var stickerUrl: URL? {
    URL(string: stickerURL ?? "")
  }
}

extension Sticker: Identifiable {
  public var id: String {
    UUID().uuidString
  }
}
