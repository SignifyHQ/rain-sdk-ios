import Foundation

public protocol RainPersonParametersEntity {
  var firstName: String { get }
  var lastName: String { get }
  var dateOfBirth: String { get }
  var nationalId: String { get }
  var countryOfIssue: String { get }
  var email: String { get }
  var phoneCountryCode: String { get }
  var phone: String { get }
  var addressLine1: String { get }
  var addressLine2: String { get }
  var city: String { get }
  var state: String { get }
  var country: String { get }
  var postalCode: String { get }
  var walletAddress: String { get }
  var iovationBlackbox: String { get }
  
  init(
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
  )
}
