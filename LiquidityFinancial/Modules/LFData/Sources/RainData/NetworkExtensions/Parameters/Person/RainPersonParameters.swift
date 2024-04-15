import Foundation
import NetworkUtilities
import RainDomain


public struct RainPersonParameters: Parameterable, RainPersonParametersEntity {
  public let firstName: String
  public let lastName: String
  public let dateOfBirth: String
  public let nationalId: String
  public let countryOfIssue: String
  public let email: String
  public let phoneCountryCode: String
  public let phone: String
  public let addressLine1: String
  public let addressLine2: String
  public let city: String
  public let state: String
  public let country: String
  public let postalCode: String
  public let walletAddress: String
  public let iovationBlackbox: String
  
  public init(
    firstName: String,
    lastName: String,
    dateOfBirth: String,
    nationalId: String,
    countryOfIssue: String,
    email: String,
    phoneCountryCode: String,
    phone: String,
    addressLine1: String,
    addressLine2: String,
    city: String,
    state: String,
    country: String,
    postalCode: String,
    walletAddress: String,
    iovationBlackbox: String
  ) {
    self.firstName = firstName
    self.lastName = lastName
    self.dateOfBirth = dateOfBirth
    self.nationalId = nationalId
    self.countryOfIssue = countryOfIssue
    self.email = email
    self.phoneCountryCode = phoneCountryCode
    self.phone = phone
    self.addressLine1 = addressLine1
    self.addressLine2 = addressLine2
    self.city = city
    self.state = state
    self.country = country
    self.postalCode = postalCode
    self.walletAddress = walletAddress
    self.iovationBlackbox = iovationBlackbox
  }
}
