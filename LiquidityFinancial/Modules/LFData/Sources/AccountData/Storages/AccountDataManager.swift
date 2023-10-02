import Foundation
import NetSpendDomain
import AccountDomain
import Combine
import LFUtilities

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
    UserDefaults.userSessionID[phoneNumber] ?? ""
  }
  
  public var userCompleteOnboarding: Bool {
    get {
      UserDefaults.userCompleteOnboarding
    }
    set {
      UserDefaults.userCompleteOnboarding = newValue
    }
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
  public var externalAccountID: String?

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
    UserDefaults.userSessionID = [phoneNumber: sessionID]
  }
  
  public func clearUserSession() {
    // we don't clear it beacause it alway map with phoneNumber
    // when the user login with multi-account on the phone
    //UserDefaults.userSessionID = [:]
    UserDefaults.phoneNumber = ""
    UserDefaults.userEmail = ""
    UserDefaults.userNameDisplay = ""
    UserDefaults.userCompleteOnboarding = false
    userInfomationData = UserInfomationData()
  }
  
  public func storeUser(user: LFUser) {
    userInfomationData = UserInfomationData(enity: user)
    if let fullName = userInfomationData.fullName, fullName.isEmpty {
      update(fullName: (userInfomationData.firstName ?? "") + " " + (userInfomationData.lastName ?? ""))
    }
  }
  
  // MARK: Wallet addresses
  public let walletAddressesSubject = CurrentValueSubject<[WalletAddressEntity], Never>([])
  
  public func subscribeWalletAddressesChanged(_ completion: @escaping ([WalletAddressEntity]) -> Void) -> Cancellable {
    walletAddressesSubject.receive(on: DispatchQueue.main).sink(receiveValue: completion)
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
  
  // MARK: linked sources
  public let linkedSourcesSubject = CurrentValueSubject<[any LinkedSourceDataEntity], Never>([])
  
  public func subscribeLinkedSourcesChanged(_ completion: @escaping ([any LinkedSourceDataEntity]) -> Void) -> Cancellable {
    linkedSourcesSubject.receive(on: DispatchQueue.main).sink(receiveValue: completion)
  }
  
  public func storeLinkedSources(_ sources: [any LinkedSourceDataEntity]) {
    linkedSourcesSubject.send(sources)
  }
  
  public func addOrEditLinkedSource(_ source: any LinkedSourceDataEntity) {
    var newValues = linkedSourcesSubject.value
    if let index = newValues.firstIndex(where: { $0.sourceId == source.sourceId }) {
      newValues.replaceSubrange(index...index, with: [source])
    } else {
      newValues.append(source)
    }
    linkedSourcesSubject.send(newValues)
  }
  
  public func removeLinkedSource(id: String) {
    var newValues = linkedSourcesSubject.value
    let count = newValues.count
    newValues.removeAll(where: { $0.sourceId == id })
    if count != newValues.count {
      linkedSourcesSubject.send(newValues)
    }
  }
  
  // MARK: Account
  public let accountsSubject = CurrentValueSubject<[LFAccount], Never>([])
  
  public var availableRewardCurrenciesSubject = CurrentValueSubject<AvailableRewardCurrenciesEntity?, Never>(nil)
  
  public var selectedRewardCurrencySubject = CurrentValueSubject<RewardCurrencyEntity?, Never>(nil)
  
  public func addOrUpdateAccounts(_ accounts: [LFAccount]) {
    for account in accounts {
      addOrUpdateAccount(account)
    }
  }
  
  public func addOrUpdateAccount(_ account: LFAccount) {
    var newValues = accountsSubject.value
    if let index = newValues.firstIndex(where: { $0.id == account.id }) {
      newValues.replaceSubrange(index...index, with: [account])
    } else {
      newValues.append(account)
    }
    accountsSubject.send(newValues)
  }
  
  // MARK: Config
  private let featureConfigSubject = CurrentValueSubject<FeatureConfigModel?, Never>(nil)
  
  public var featureConfig: FeatureConfigModel? {
    get {
      featureConfigSubject.value
    }
    set {
      featureConfigSubject.send(newValue)
    }
  }
}
