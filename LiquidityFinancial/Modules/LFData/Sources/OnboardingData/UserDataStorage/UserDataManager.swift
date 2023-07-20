import Foundation

public protocol UserDataManagerProtocol {
  var userInfomationData: UserInfomationData { get }
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
}

public class UserDataManager: UserDataManagerProtocol {
  public private(set) var userInfomationData = UserInfomationData()
  
  public func update(firstName: String?) {
    self.userInfomationData.firstName = firstName
  }
  
  public func update(lastName: String?) {
    self.userInfomationData.lastName = lastName
  }
  
  public func update(phone: String?) {
    self.userInfomationData.phone = phone
  }
  
  public func update(email: String?) {
    self.userInfomationData.email = email
  }
  
  public func update(fullName: String?) {
    self.userInfomationData.fullName = fullName
  }
  
  public func update(dateOfBirth: String?) {
    self.userInfomationData.dateOfBirth = dateOfBirth
  }
  
  public func update(addressLine1: String?) {
    self.userInfomationData.addressLine1 = addressLine1
  }
  
  public func update(addressLine2: String?) {
    self.userInfomationData.addressLine2 = addressLine2
  }
  
  public func update(city: String?) {
    self.userInfomationData.city = city
  }
  
  public func update(state: String?) {
    self.userInfomationData.state = state
  }
  
  public func update(postalCode: String?) {
    self.userInfomationData.postalCode = postalCode
  }
  
  public func update(country: String?) {
    self.userInfomationData.country = country
  }
  
  public func update(encryptedData: String?) {
    self.userInfomationData.encryptedData = encryptedData
  }
  
  public func update(ssn: String?) {
    self.userInfomationData.ssn = ssn
  }
  
  public func update(passport: String?) {
    self.userInfomationData.passport = passport
  }
}
