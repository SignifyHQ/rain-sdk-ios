import Foundation
import LFUtilities

// MARK: - Fundraiser

struct Fundraiser: Hashable, Identifiable {
  let id: String
  let name: String
  let description: String?
  let url: URL?
  let goal: Int?
  let charity: Charity
  let sticker: Sticker
  let causes: [Cause]
  let backgroundColor: String?

  // The amount donated by the community to this fundraiser.
  let communityAmount: Double
  // The number of donations made by the community to this fundraiser.
  let communityDonations: Int
  // The amount donated by Liquidity to this fundraiser.
  let liquidityAmount: Double
  // The number of donations made by Liquidity to this fundraiser.
  let liquidityDonations: Int

  var currentAmount: Double {
    communityAmount + liquidityAmount
  }

  var currentDonations: Int {
    communityDonations + liquidityDonations
  }
}

extension Fundraiser: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    url = try container.decodeUrl(forKey: .url)
    goal = try container.decodeIfPresent(Int.self, forKey: .goal)
    charity = try container.decode(Charity.self, forKey: .charity)
    sticker = try container.decode(Sticker.self, forKey: .sticker)
    causes = try container.decodeIfPresent([Cause].self, forKey: .causes)?.sorted(by: { $0.rank < $1.rank }) ?? []
    backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
    communityAmount = try container.decodeIfPresent(Double.self, forKey: .communityAmount) ?? 0
    communityDonations = try container.decodeIfPresent(Int.self, forKey: .communityDonations) ?? 0
    liquidityAmount = try container.decodeIfPresent(Double.self, forKey: .liquidityAmount) ?? 0
    liquidityDonations = try container.decodeIfPresent(Int.self, forKey: .liquidityDonations) ?? 0
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case description
    case url
    case goal
    case charity = "donationCharity"
    case sticker = "donationCharityFundraiserSticker"
    case causes = "categories"
    case backgroundColor
    case communityAmount = "totalCommunityDonationAmount"
    case communityDonations = "totalNumberOfCommunityDonations"
    case liquidityAmount = "totalLiquidityDonationAmount"
    case liquidityDonations = "totalNumberOfLiquidityDonations"
  }
}

extension Fundraiser {
  // The API is returning a dummy Fundraiser instead of returning null.
  // We need to manually ignore it so that the app doesn't show that a dummy fundraiser is selected.
  var isValid: Bool {
    id != "00000000-0000-0000-0000-000000000000"
  }
}
