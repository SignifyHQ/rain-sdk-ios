import Foundation

public protocol LFUser {
  var userID: String { get }
  var firstName: String? { get }
  var lastName: String? { get }
  var fullName: String? { get }
  var phone: String? { get }
  var email: String? { get }
  var addressEntity: AddressEntity? { get }
  var referralLink: String? { get }
  var userRewardType: String? { get }
  var userAccessLevel: String? { get }
  var userSelectedFundraiserId: String? { get }
  var userRoundUpEnabled: Bool? { get }
  var accountReviewStatus: String? { get }
  var transferLimitConfigsEntity: [TransferLimitConfigEntity] { get }
}
