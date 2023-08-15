import Foundation

public protocol FundraisersDetailEntity {
  associatedtype APIFundraiserEnity: FundraiserEnity
  associatedtype APICharityEnity: CharityEnity
  associatedtype APILatestDonationEnity: LatestDonationEnity
  var fundraiser: APIFundraiserEnity? { get }
  var charity: APICharityEnity? { get }
  var currentDonatedAmount: Int? { get }
  var currentDonatedCount: Int? { get }
  var latestDonations: [APILatestDonationEnity]? { get }
}

  // MARK: - Charity
public protocol CharityEnity {
  var id: String? { get }
  var productId: String? { get }
  var name: String? { get }
  var description: String? { get }
  var logoUrl: String? { get }
  var headerUrl: String? { get }
  var headerImageUrl: String? { get }
  var url: String? { get }
  var twitterUrl: String? { get }
  var facebookUrl: String? { get }
  var instagramUrl: String? { get }
  var confidence: Int? { get }
  var address: String? { get }
  var ein: String? { get }
  var tags: [String]? { get }
}

  // MARK: - Fundraiser
public protocol FundraiserEnity {
  var id: String? { get }
  var name: String? { get }
  var description: String? { get }
  var stickerUrl: String? { get }
  var createdAt: String? { get }
  var goal: Int? { get }
  var currency: String? { get }
  var isFeatured: Bool? { get }
  var isLive: Bool? { get }
  var categories: [String]? { get }
}

  // MARK: - LatestDonation
public protocol LatestDonationEnity {
  var id: String? { get }
  var fundraiserId: String? { get }
  var userId: String? { get }
  var userName: String? { get }
  var amount: Int? { get }
  var createdAt: String? { get }
}
