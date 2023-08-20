import Foundation
import RewardData
import RewardDomain
import NetworkUtilities
  // MARK: - Fundraiser
struct FundraiserDetailModel: Equatable, Identifiable {
  var id: String = UUID().uuidString
  
  static func == (lhs: FundraiserDetailModel, rhs: FundraiserDetailModel) -> Bool {
    return lhs.id == rhs.id
  }
  
  let fundraiser: Fundraiser?
  let charity: Charity?
  let currentDonatedAmount, currentDonatedCount: Double?
  let latestDonations: [LatestDonation]?
  
  var name: String {
    fundraiser?.name ?? "unknown"
  }
  
  var charityName: String {
    charity?.name ?? "unknown"
  }
  
  var stickerUrl: URL? {
    URL(string: fundraiser?.stickerUrl ?? "unknown")
  }
  
  var charityUrl: URL? {
    URL(string: charity?.url ?? "unknown")
  }
  
  var charityHeaderUrl: URL? {
    URL(string: charity?.headerUrl ?? "unknown")
  }
  
  var charityHeaderImageUrl: URL? {
    URL(string: charity?.headerImageUrl ?? "unknown")
  }
  
  var currentAmount: Double {
    currentDonatedAmount ?? 0
  }
  
  var currentDonations: Double {
    currentDonatedCount ?? 0
  }
  
  var description: String? {
    fundraiser?.description
  }
  
  var twitterUrl: URL? {
    URL(string: charity?.twitterUrl ?? "unknown")
  }
  
  var facebookUrl: URL? {
    URL(string: charity?.facebookUrl ?? "unknown")
  }
  
  var instagramUrl: URL? {
    URL(string: charity?.instagramUrl ?? "unknown")
  }
  
  var charityEmailUrl: URL? {
    URL(string: charity?.emailListUrl ?? "unknown")
  }
  
  var charityNavigatorUrl: URL? {
    URL(string: charity?.charityNavigatorUrl ?? "unknown")
  }
  
    // MARK: - Charity
  struct Charity {
    let id, productId, name, description: String?
    let logoUrl, headerUrl, headerImageUrl, url: String?
    let twitterUrl, facebookUrl, instagramUrl: String?
    let confidence: Double?
    let address, ein: String?
    let charityNavigatorUrl: String?
    let emailListUrl: String?
    let tags: [String]?
    
    init?(enity: (any CharityEnity)?) {
      guard let enity = enity else { return nil }
      self.id = enity.id
      self.productId = enity.productId
      self.name = enity.name
      self.description = enity.description
      self.logoUrl = enity.logoUrl
      self.headerUrl = enity.headerUrl
      self.headerImageUrl = enity.headerImageUrl
      self.url = enity.url
      self.twitterUrl = enity.twitterUrl
      self.facebookUrl = enity.facebookUrl
      self.instagramUrl = enity.instagramUrl
      self.confidence = enity.confidence
      self.address = enity.address
      self.ein = enity.ein
      self.tags = enity.tags
      self.emailListUrl = enity.emailListUrl
      self.charityNavigatorUrl = enity.charityNavigatorUrl
    }
    
    var confidenceValue: Double {
      confidence ?? 0.0
    }
  }
  
    // MARK: - Fundraiser
  struct Fundraiser {
    let id, name, description, stickerUrl, backgroundColor: String?
    let createdAt: String?
    let goal: Double?
    let currency: String?
    let isFeatured, isLive: Bool?
    let categories: [String]?
    
    init?(enity: (any FundraiserEnity)?) {
      guard let enity = enity else { return nil }
      self.id = enity.id
      self.name = enity.name
      self.description = enity.description
      self.stickerUrl = enity.stickerUrl
      self.createdAt = enity.createdAt
      self.goal = enity.goal
      self.currency = enity.currency
      self.isFeatured = enity.isFeatured
      self.isLive = enity.isLive
      self.categories = enity.categories
      self.backgroundColor = enity.backgroundColor
    }
  }
  
    // MARK: - LatestDonation
  struct LatestDonation {
    let id, fundraiserId, userId, userName: String?
    let amount: Double?
    let createdAt: String?
    
    init?(enity: (any LatestDonationEnity)?) {
      guard let enity = enity else { return nil }
      self.id = enity.id
      self.fundraiserId = enity.fundraiserId
      self.userId = enity.userId
      self.userName = enity.userName
      self.amount = enity.amount
      self.createdAt = enity.createdAt
    }
  }
  
  init(enity: any FundraisersDetailEntity) {
    self.fundraiser = Fundraiser(enity: enity.fundraiser)
    self.charity = Charity(enity: enity.charity)
    self.latestDonations = enity.latestDonations?.compactMap({ LatestDonation(enity: $0) })
    self.currentDonatedAmount = enity.currentDonatedAmount
    self.currentDonatedCount = enity.currentDonatedCount
  }
}
