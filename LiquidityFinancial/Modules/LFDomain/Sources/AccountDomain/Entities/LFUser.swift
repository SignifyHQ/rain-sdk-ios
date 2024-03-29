import Foundation
import NetspendDomain

// sourcery: AutoMockable
public enum AccountReviewStatus: String {
  case approved
  case rejected
  case inreview
  case reviewing
}

public protocol LFUser {
  var userID: String { get }
  var firstName: String? { get }
  var lastName: String? { get }
  var fullName: String? { get }
  var phone: String? { get }
  var phoneVerified: Bool? { get }
  var email: String? { get }
  var emailVerified: Bool? { get }
  var mfaEnabled: Bool? { get }
  var addressEntity: AddressEntity? { get }
  var referralLink: String? { get }
  var userRewardType: String? { get }
  var userAccessLevel: String? { get }
  var userSelectedFundraiserId: String? { get }
  var userRoundUpEnabled: Bool? { get }
  var accountReviewStatus: String? { get }
  var missingSteps: [String]? { get }
}

public extension LFUser {
  var accountReviewStatusEnum: AccountReviewStatus? {
    guard let value = accountReviewStatus else { return nil }
    return AccountReviewStatus(rawValue: value)
  }
}
