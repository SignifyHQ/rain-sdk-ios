import Foundation

  // MARK: - Contribution

struct ContributionModel: Hashable {
    /// The currently selected Fundraiser (if any).
  var selectedFundraiser: FundraiserModel?
  
    // The amount donated by the user to all charities.
  let totalAmount: Double
  
    // The number of donations made by the user to all charities.
  let totalDonations: Int
  
    // The amount donated by the user to the selected charity.
  let selectedCharityAmount: Double
  
    // The number of donations made by the user to the selected charity.
  let selectedCharityDonations: Int
  
    // The stickers earned by this user
  let stickers: [StickerModel]
}
