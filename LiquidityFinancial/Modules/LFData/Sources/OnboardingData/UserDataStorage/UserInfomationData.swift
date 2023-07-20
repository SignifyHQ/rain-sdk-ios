import Foundation

public struct UserInfomationData {
  public var firstName, lastName, middleName: String?
  public var agreementIDS: [String] = []
  public var phone, email, fullName, dateOfBirth: String?
  public var addressLine1, addressLine2, city, state: String?
  public var country, postalCode, encryptedData: String?
  public var ssn, passport: String?
}
