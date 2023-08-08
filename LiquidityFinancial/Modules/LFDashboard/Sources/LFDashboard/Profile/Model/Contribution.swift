import Foundation

struct Contribution {
  var selectedFundraiser: Fundraiser?
  let totalAmount: Double
  let totalDonations: Int
  let selectedCharityAmount: Double
  let selectedCharityDonations: Int
  let stickers: [Sticker]
}
