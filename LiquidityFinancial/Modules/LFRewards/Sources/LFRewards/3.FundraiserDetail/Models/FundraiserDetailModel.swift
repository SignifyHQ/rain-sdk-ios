import Foundation
import RewardData
import RewardDomain
import NetworkUtilities

// MARK: - Fundraiser
public typealias LFCharityModel = FundraiserDetailModel.Charity
public typealias LFFundraiserModel = FundraiserDetailModel.Fundraiser
public typealias LFLatestDonationModel = FundraiserDetailModel.LatestDonation

public struct FundraiserDetailModel: Equatable, Identifiable {
  public var id: String = UUID().uuidString
  
  public static func == (lhs: FundraiserDetailModel, rhs: FundraiserDetailModel) -> Bool {
    return lhs.id == rhs.id
  }
  
  public let fundraiser: Fundraiser?
  public let charity: Charity?
  public let currentDonatedAmount, currentDonatedCount: Double?
  public let latestDonations: [LatestDonation]?
  
  public var name: String {
    fundraiser?.name ?? "unknown"
  }
  
  public var charityName: String {
    charity?.name ?? "unknown"
  }
  
  public var stickerUrl: URL? {
    URL(string: fundraiser?.stickerUrl ?? "unknown")
  }
  
  public var charityUrl: URL? {
    URL(string: charity?.url ?? "unknown")
  }
  
  public var charityHeaderUrl: URL? {
    URL(string: charity?.headerUrl ?? "unknown")
  }
  
  public var charityHeaderImageUrl: URL? {
    URL(string: charity?.headerImageUrl ?? "unknown")
  }
  
  public var currentAmount: Double {
    currentDonatedAmount ?? 0
  }
  
  public var currentDonations: Double {
    currentDonatedCount ?? 0
  }
  
  public var description: String? {
    fundraiser?.description
  }
  
  public var twitterUrl: URL? {
    URL(string: charity?.twitterUrl ?? "unknown")
  }
  
  public var facebookUrl: URL? {
    URL(string: charity?.facebookUrl ?? "unknown")
  }
  
  public var instagramUrl: URL? {
    URL(string: charity?.instagramUrl ?? "unknown")
  }
  
  public var charityEmailUrl: URL? {
    URL(string: charity?.emailListUrl ?? "unknown")
  }
  
  public var charityNavigatorUrl: URL? {
    URL(string: charity?.charityNavigatorUrl ?? "unknown")
  }
  
    // MARK: - Charity
  public struct Charity {
    public let id, productId, name, description: String?
    public let logoUrl, headerUrl, headerImageUrl, url: String?
    public let twitterUrl, facebookUrl, instagramUrl: String?
    public let confidence: Double?
    public let address, ein: String?
    public let charityNavigatorUrl: String?
    public let emailListUrl: String?
    public let tags: [String]?
    
    public init?(enity: (any CharityEnity)?) {
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
    
    public var confidenceValue: Double {
      confidence ?? 0.0
    }
  }
  
    // MARK: - Fundraiser
  public struct Fundraiser {
    public let id, name, description, stickerUrl, backgroundColor: String?
    public let createdAt: String?
    public let goal: Double?
    public let currency: String?
    public let isFeatured, isLive: Bool?
    public let categories: [String]?
    
    public init?(enity: (any FundraiserEnity)?) {
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
  public struct LatestDonation {
    public let id, fundraiserId, userId, userName: String?
    public let amount: Double?
    public let createdAt: String?
    
    public init?(enity: (any LatestDonationEnity)?) {
      guard let enity = enity else { return nil }
      self.id = enity.id
      self.fundraiserId = enity.fundraiserId
      self.userId = enity.userId
      self.userName = enity.userName
      self.amount = enity.amount
      self.createdAt = enity.createdAt
    }
  }
  
  public init(enity: any FundraisersDetailEntity) {
    self.fundraiser = Fundraiser(enity: enity.fundraiser)
    self.charity = Charity(enity: enity.charity)
    self.latestDonations = enity.latestDonations?.compactMap({ LatestDonation(enity: $0) })
    self.currentDonatedAmount = enity.currentDonatedAmount
    self.currentDonatedCount = enity.currentDonatedCount
  }
}
