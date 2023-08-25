import Foundation
import AccountDomain

public struct APIReferralCampaign: Decodable, ReferralCampaignEntity {
  public let maxRewardAmountPerReferee, rewardDuration: Int?
  public let rewardDurationTimeUnit: String?
}
