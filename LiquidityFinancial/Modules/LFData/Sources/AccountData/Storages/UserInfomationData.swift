import Foundation
import LFUtilities
import AccountDomain

public struct UserInfomationData: Codable, UserInfomationDataProtocol {
  public var userID: String?
  public var firstName, lastName, middleName: String?
  public var agreementIDS: [String] = []
  public var phoneCode, phone, email, fullName, dateOfBirth: String?
  public var phoneVerified, emailVerified, mfaEnabled: Bool?
  public var addressLine1, addressLine2, city, state: String?
  public var country, countryCode, postalCode, encryptedData: String?
  public var ssn, passport: String?
  public var referralLink: String?
  public var userRewardType: String?
  public var userAccessLevel: String?
  public var userSelectedFundraiserID: String?
  public var userRoundUpEnabled: Bool?
  public var accountReviewStatus: String?
  public var missingSteps: [String]?
  
  public init() {}
  
  public init(entity: LFUser) {
    self.userID = entity.userID
    self.firstName = entity.firstName
    self.lastName = entity.lastName
    self.fullName = entity.fullName
    self.phone = entity.phone
    self.phoneVerified = entity.phoneVerified
    self.email = entity.email
    self.emailVerified = entity.emailVerified
    self.mfaEnabled = entity.mfaEnabled
    //self.dateOfBirth = entity.firstName
    self.addressLine1 = entity.addressEntity?.line1
    self.addressLine2 = entity.addressEntity?.line2
    self.city = entity.addressEntity?.city
    self.state = entity.addressEntity?.state
    self.country = entity.addressEntity?.country
    self.countryCode = entity.addressEntity?.countryCode
    self.postalCode = entity.addressEntity?.postalCode
    self.accountReviewStatus = entity.accountReviewStatus
    self.referralLink = entity.referralLink
    self.userRewardType = entity.userRewardType
    self.userAccessLevel = entity.userAccessLevel
    self.userRoundUpEnabled = entity.userRoundUpEnabled
    self.userSelectedFundraiserID = entity.userSelectedFundraiserId
    self.missingSteps = entity.missingSteps
  }
  
  public enum AccessLevel: String {
    case LIVE, INTERNAL, DISABLED, EXPERIMENTAL, NONE
  }
  
  public var accessLevel: AccessLevel {
    AccessLevel(rawValue: userAccessLevel ?? "") ?? .NONE
  }
  
  public enum MissingStepsEnum: String {
    case createPassword = "CREATE_PASSWORD"
    case verifyEmail = "VERIFY_EMAIL"
  }
  
  public var missingStepsEnum: [MissingStepsEnum]? {
    guard let value = missingSteps else { return nil }
    return value
      .compactMap { string in
        MissingStepsEnum(rawValue: string)
      }
  }
}
