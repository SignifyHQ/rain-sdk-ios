import Foundation
import RewardDomain

public struct APIUserDonationSummary: Decodable, UserDonationSummaryEntity {
  public let donationCount: Int?
  public let donationAmount: Double?
  public let stickers: [APIDonationSticker]
}

public struct APIDonationSticker: Decodable, DonationStickerEntity {
  public let fundraiserId, stickerUrl: String?
  public let donationCount: Int?
}
