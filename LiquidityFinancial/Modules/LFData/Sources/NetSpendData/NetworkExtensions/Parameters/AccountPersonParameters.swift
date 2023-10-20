import Foundation
import NetworkUtilities
import NetspendDomain

public enum IdNumberType: String {
  case ssn, passport
  case nonUsPassport = "non_us_passport"
}

public struct AccountPersonParameters: Parameterable, AccountPersonParametersEntity {
  public let firstName, lastName, middleName: String
  public let agreementIds: [String]
  public let phone, email, fullName, dateOfBirth: String
  public let addressLine1, addressLine2, city, state: String
  public let country, postalCode, encryptedData: String
  public let idNumber: String
  public let idNumberType: String
  public init(firstName: String, lastName: String, middleName: String, agreementIDS: [String], phone: String, email: String, fullName: String, dateOfBirth: String, addressLine1: String, addressLine2: String, city: String, state: String, country: String, postalCode: String, encryptedData: String, idNumber: String, idNumberType: String) {
    self.firstName = firstName
    self.lastName = lastName
    self.middleName = middleName
    self.agreementIds = agreementIDS
    self.phone = phone
    self.email = email
    self.fullName = fullName
    self.dateOfBirth = dateOfBirth
    self.addressLine1 = addressLine1
    self.addressLine2 = addressLine2
    self.city = city
    self.state = state
    self.country = country
    self.postalCode = postalCode
    self.encryptedData = encryptedData
    self.idNumber = idNumber
    self.idNumberType = idNumberType
  }
}
