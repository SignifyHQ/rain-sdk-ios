import Foundation

public protocol SelectFundraiserEntity {
  var userRewardType: String? { get }
  var userSelectedFundraiserId: String? { get }
  var userRoundUpEnabled: Bool? { get }
}
