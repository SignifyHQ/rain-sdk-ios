import Foundation

public protocol AccountPersonDataEntity {
  var liquidityAccountId: String { get }
  var externalAccountId: String { get }
  var externalPersonId: String { get }
}

public protocol AccountPersonParametersEntity {
  var firstName: String { get }
  var lastName: String { get }
  var middleName: String { get }
  var agreementIds: [String] { get }
  var phone: String { get }
  var email: String { get }
  var dateOfBirth: String { get }
  var addressLine1: String { get }
  var addressLine2: String { get }
  var city: String { get }
  var state: String { get }
  var country: String { get }
  var postalCode: String { get }
  var encryptedData: String { get }
  var idNumber: String { get }
  var idNumberType: String { get }
  init(firstName: String, lastName: String, middleName: String, agreementIDS: [String], phone: String, email: String, fullName: String, dateOfBirth: String, addressLine1: String, addressLine2: String, city: String, state: String, country: String, postalCode: String, encryptedData: String, idNumber: String, idNumberType: String)
}
