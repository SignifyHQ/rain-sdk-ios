import Foundation
import AccountDomain
import Combine

public class AccountDataManager: AccountDataStorageProtocol {
  public func update(addressEntity: AddressEntity?) {
    update(addressLine1: addressEntity?.line1)
    update(addressLine2: addressEntity?.line2)
    update(city: addressEntity?.city)
    update(state: addressEntity?.state)
    update(country: addressEntity?.country)
    update(postalCode: addressEntity?.postalCode)
  }
  
  public var userNameDisplay: String {
    get {
      UserDefaults.userNameDisplay
    }
    set {
      UserDefaults.userNameDisplay = newValue
    }
  }
  
  public var userEmail: String {
    get {
      UserDefaults.userEmail
    }
    set {
      UserDefaults.userEmail = newValue
    }
  }
  
  public var phoneNumber: String {
    UserDefaults.phoneNumber
  }
  
  public var sessionID: String {
    UserDefaults.userSessionID
  }
  
  public var addressDetail: String {
    let userData = self.userInfomationData
    let stateCode = "\(userData.state ?? "") - \(userData.postalCode ?? "")"
    let addressDetails = [userData.addressLine1, userData.addressLine2, userData.city, stateCode, userData.country]
    return addressDetails
      .compactMap { $0 }
      .filter { !$0.isEmpty }
      .joined(separator: ", ")
  }

  public var fiatAccountID: String?
  public var cryptoAccountID: String?

  public private(set) var userInfomationData: UserInfomationDataProtocol = UserInfomationData()
  
  public func update(userID: String?) {
    self.userInfomationData.userID = userID
  }
  
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
  
  public func update(referralLink: String?) {
    self.userInfomationData.referralLink = referralLink
  }
  
  public func stored(phone: String) {
    UserDefaults.phoneNumber = phone
  }
  
  public func stored(sessionID: String) {
    UserDefaults.userSessionID = sessionID
  }
  
  public func clearUserSession() {
    UserDefaults.userSessionID = ""
    UserDefaults.phoneNumber = ""
    userInfomationData = UserInfomationData()
  }
  
  public func storeUser(user: LFUser) {
    userInfomationData = UserInfomationData(enity: user)
    if let fullName = userInfomationData.fullName, fullName.isEmpty {
      update(fullName: (userInfomationData.firstName ?? "") + " " + (userInfomationData.lastName ?? ""))
    }
  }
  
  public let walletAddressesSubject = CurrentValueSubject<[WalletAddressEntity], Never>([])
  
  public func subscribeWalletAddressesChanged(_ completion: @escaping ([WalletAddressEntity]) -> Void) -> Cancellable {
    walletAddressesSubject.sink(receiveValue: completion)
  }
  
  public func storeWalletAddresses(_ addresses: [WalletAddressEntity]) {
    walletAddressesSubject.send(addresses)
  }
  
  public func addOrEditWalletAddress(_ address: WalletAddressEntity) {
    var newValues = walletAddressesSubject.value
    if let index = newValues.firstIndex(where: { $0.id == address.id }) {
      newValues.replaceSubrange(index...index, with: [address])
    } else {
      newValues.append(address)
    }
    walletAddressesSubject.send(newValues)
  }
  
  public func removeWalletAddress(id: String) {
    var newValues = walletAddressesSubject.value
    let count = newValues.count
    newValues.removeAll(where: { $0.id == id })
    if count != newValues.count {
      walletAddressesSubject.send(newValues)
    }
  }
}
