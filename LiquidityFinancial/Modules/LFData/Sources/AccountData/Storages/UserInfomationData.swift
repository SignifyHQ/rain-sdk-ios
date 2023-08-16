import Foundation
import LFUtilities
import AccountDomain

public struct UserInfomationData: Codable, UserInfomationDataProtocol {
  public var userID: String?
  public var firstName, lastName, middleName: String?
  public var agreementIDS: [String] = []
  public var phone, email, fullName, dateOfBirth: String?
  public var addressLine1, addressLine2, city, state: String?
  public var country, postalCode, encryptedData: String?
  public var ssn, passport: String?
  public var referralLink: String?
  public var userRewardType: String?
  public var userAccessLevel: String?
  public var userSelectedFundraiserID: String?
  public var userRoundUpEnabled: Bool?
  public var accountReviewStatus: String?
  
  public init() {}
  
  public init(enity: LFUser) {
    self.userID = enity.userID
    self.firstName = enity.firstName
    self.lastName = enity.lastName
    self.fullName = enity.fullName
    self.phone = enity.phone
    self.email = enity.email
    //self.dateOfBirth = enity.firstName
    self.addressLine1 = enity.addressEntity?.line1
    self.addressLine2 = enity.addressEntity?.line2
    self.city = enity.addressEntity?.city
    self.state = enity.addressEntity?.state
    self.country = enity.addressEntity?.country
    self.postalCode = enity.addressEntity?.postalCode
    self.accountReviewStatus = enity.accountReviewStatus
    self.referralLink = enity.referralLink
    self.userRewardType = enity.userRewardType
    self.userAccessLevel = enity.userAccessLevel
    self.userRoundUpEnabled = enity.userRoundUpEnabled
    self.userSelectedFundraiserID = enity.userSelectedFundraiserID
  }
}
