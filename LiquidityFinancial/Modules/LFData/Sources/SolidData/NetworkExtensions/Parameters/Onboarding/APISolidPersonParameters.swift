import Foundation
import NetworkUtilities
import SolidDomain

// MARK: - APISolidPerson
public struct APISolidPersonParameters: Parameterable, SolidPersonParametersEntity {
  public var solidCreatePersonRequest: SolidCreatePersonRequest
  
  public init(solidCreatePersonRequest: SolidCreatePersonRequest) {
    self.solidCreatePersonRequest = solidCreatePersonRequest
  }
}

// MARK: - SolidCreatePersonRequest
public struct SolidCreatePersonRequest: Parameterable {
  public let firstName, middleName, lastName, email, phone: String?
  public let dateOfBirth, idNumber, idType: String?
  public let address: SolidAddress?
  
  public init(firstName: String?, middleName: String?, lastName: String?, email: String?, phone: String?, dateOfBirth: String?, idNumber: String?, idType: String?, address: SolidAddress?) {
    self.firstName = firstName
    self.middleName = middleName
    self.lastName = lastName
    self.email = email
    self.phone = phone
    self.dateOfBirth = dateOfBirth
    self.idNumber = idNumber
    self.idType = idType
    self.address = address
  }
}

// MARK: - Address
public struct SolidAddress: Parameterable {
  public let line1, line2, city, state: String?
  public let country, postalCode: String?
  
  public init(line1: String?, line2: String?, city: String?, state: String?, country: String?, postalCode: String?) {
    self.line1 = line1
    self.line2 = line2
    self.city = city
    self.state = state
    self.country = country
    self.postalCode = postalCode
  }
}
