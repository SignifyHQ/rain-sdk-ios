import Foundation
import LFRewards
import RewardDomain

struct Contribution {
  let donationAmount: Double
  let donationCount: Int
  let stickers: [Sticker]
  
  init(entity: any UserDonationSummaryEntity) {
    self.donationAmount = entity.donationAmount ?? 0
    self.donationCount = entity.donationCount ?? 0
    self.stickers = entity.stickers.compactMap({ Sticker(entity: $0) })
  }
}
