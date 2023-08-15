import Foundation
import RewardDomain

public struct APIRoundUpDonation: Decodable, RoundUpDonationEntity {
  public let userRewardType: String?
  public let userSelectedFundraiserId: String?
  public let userRoundUpEnabled: Bool?
}
