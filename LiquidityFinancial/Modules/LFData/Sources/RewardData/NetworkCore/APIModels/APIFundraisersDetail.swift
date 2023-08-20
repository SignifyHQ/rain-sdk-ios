import Foundation
import RewardDomain

public struct APIFundraisersDetail: Decodable, FundraisersDetailEntity {
  public let fundraiser: APIFundraiser?
  public let charity: APICharity?
  public let currentDonatedAmount, currentDonatedCount: Double?
  public let latestDonations: [APILatestDonation]?
}

  // MARK: - Charity
public struct APICharity: Decodable, CharityEnity {
  public var emailListUrl: String?
  public var charityNavigatorUrl: String?
  public let id, productId, name, description: String?
  public let logoUrl, headerUrl, headerImageUrl, url: String?
  public let twitterUrl, facebookUrl, instagramUrl: String?
  public let confidence: Double?
  public let address, ein: String?
  public let tags: [String]?
}

  // MARK: - Fundraiser
public struct APIFundraiser: Decodable, FundraiserEnity {
  public let id, name, description, stickerUrl, backgroundColor: String?
  public let createdAt: String?
  public let goal: Double?
  public let currency: String?
  public let isFeatured, isLive: Bool?
  public let categories: [String]?
}

  // MARK: - LatestDonation
public struct APILatestDonation: Decodable, LatestDonationEnity {
  public let title: String?
  public let amount: Double?
  public let stickerUrl: String?
  public let status: String?
  public let id, fundraiserId, userId, userName: String?
  public let createdAt: String?
}
