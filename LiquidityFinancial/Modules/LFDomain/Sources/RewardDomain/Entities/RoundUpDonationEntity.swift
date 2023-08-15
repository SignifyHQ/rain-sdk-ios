import Foundation

public protocol RoundUpDonationEntity {
  var userRewardType: String? { get }
  var userSelectedFundraiserId: String? { get }
  var userRoundUpEnabled: Bool? { get }
}
