import Foundation

// sourcery: AutoMockable

public protocol RainPersonParametersEntity {
  var firstName: String { get }
  var lastName: String { get }
  var birthDate: String { get }
  var nationalId: String { get }
  var countryOfIssue: String { get }
  var email: String { get }
  var addressEntity: RainAddressParametersEntity { get }
  var phoneCountryCode: String { get }
  var phoneNumber: String { get }
  var iovationBlackbox: String { get }
}
