import Foundation
import NetworkUtilities
import RainDomain


public struct APIRainPersonParameters: Parameterable, RainPersonParametersEntity {
  public let firstName: String
  public let lastName: String
  public let birthDate: String
  public let nationalId: String
  public let countryOfIssue: String
  public let email: String
  public let address: RainAddressParameters
  public let phoneCountryCode: String
  public let phoneNumber: String
  public var occupation: String?
  public var annualSalary: String?
  public var accountPurpose: String?
  public var expectedMonthlyVolume: String?
  public let iovationBlackbox: String
  
  public var addressEntity: RainDomain.RainAddressParametersEntity {
    address
  }
  
  public init(
    firstName: String,
    lastName: String,
    birthDate: String,
    nationalId: String,
    countryOfIssue: String,
    email: String,
    address: RainAddressParameters,
    phoneCountryCode: String,
    phoneNumber: String,
    occupation: String?,
    annualSalary: String?,
    accountPurpose: String?,
    expectedMonthlyVolume: String?,
    iovationBlackbox: String
  ) {
    self.firstName = firstName
    self.lastName = lastName
    self.birthDate = birthDate
    self.nationalId = nationalId
    self.countryOfIssue = countryOfIssue
    self.email = email
    self.address = address
    self.phoneCountryCode = phoneCountryCode
    self.phoneNumber = phoneNumber
    self.occupation = occupation
    self.annualSalary = annualSalary
    self.accountPurpose = accountPurpose
    self.expectedMonthlyVolume = expectedMonthlyVolume
    self.iovationBlackbox = iovationBlackbox
  }
}
