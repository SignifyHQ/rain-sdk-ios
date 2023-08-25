import Foundation
import RewardDomain

// MARK: - Sticker

struct Sticker: Hashable, Identifiable {
  var id: String = UUID().uuidString
  let fundraiserID, stickerURL: String?
  let donationCount: Int?
  
  init(entity: DonationStickerEntity) {
    self.fundraiserID = entity.fundraiserId
    self.stickerURL = entity.stickerUrl
    self.donationCount = entity.donationCount
  }
  
  var stickerUrl: URL? {
    URL(string: stickerURL ?? "")
  }
}
