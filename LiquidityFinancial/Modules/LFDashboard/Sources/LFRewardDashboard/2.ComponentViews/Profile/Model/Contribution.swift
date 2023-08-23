import Foundation
import LFRewards
struct Contribution {
  var selectedFundraiser: FundraiserDetailModel?
  let totalAmount: Double
  let totalDonations: Int
  let selectedCharityAmount: Double
  let selectedCharityDonations: Int
  let stickers: [Sticker]
}
