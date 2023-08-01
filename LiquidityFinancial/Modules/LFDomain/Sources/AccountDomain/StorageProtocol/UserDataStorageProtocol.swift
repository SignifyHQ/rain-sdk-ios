import Foundation

public protocol AccountDataStorageProtocol {
  var userInfomationData: UserInfomationDataProtocol { get }
  var phoneNumber: String { get }
  var sessionID: String { get }
  var userNameDisplay: String { get set }
  var userEmail: String { get set }
  
  func update(firstName: String?)
  func update(lastName: String?)
  func update(phone: String?)
  func update(email: String?)
  func update(fullName: String?)
  func update(dateOfBirth: String?)
  func update(addressLine1: String?)
  func update(addressLine2: String?)
  func update(encryptedData: String?)
  func update(ssn: String?)
  func update(passport: String?)
  func update(city: String?)
  func update(state: String?)
  func update(postalCode: String?)
  func update(country: String?)
  func stored(phone: String)
  func stored(sessionID: String)
  func clearUserSession()
}

public protocol UserInfomationDataProtocol {
  var firstName: String? { get set }
  var lastName: String? { get set }
  var middleName: String? { get set }
  var agreementIDS: [String] { get set }
  var phone: String? { get set }
  var email: String? { get set }
  var fullName: String? { get set }
  var dateOfBirth: String? { get set }
  var addressLine1: String? { get set }
  var addressLine2: String? { get set }
  var city: String? { get set }
  var state: String? { get set }
  var country: String? { get set }
  var postalCode: String? { get set }
  var encryptedData: String? { get set }
  var ssn: String? { get set }
  var passport: String? { get set }
}
