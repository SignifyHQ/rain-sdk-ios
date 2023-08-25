import Foundation

public protocol ReferralCampaignEntity {
  var maxRewardAmountPerReferee: Int? { get }
  var rewardDuration: Int? { get }
  var rewardDurationTimeUnit: String? { get }
}
