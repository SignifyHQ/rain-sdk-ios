import Foundation
import Combine

public protocol AccountDataStorageProtocol {
  var userInfomationData: UserInfomationDataProtocol { get }
  var phoneNumber: String { get }
  var sessionID: String { get }
  var userNameDisplay: String { get set }
  var userEmail: String { get set }
  var addressDetail: String { get }
  var fiatAccountID: String? { get set }
  var cryptoAccountID: String? { get set }
  var userCompleteOnboarding: Bool { get set }
  
  func subscribeWalletAddressesChanged(_ completion: @escaping ([WalletAddressEntity]) -> Void) -> Cancellable
  func storeWalletAddresses(_ addresses: [WalletAddressEntity])
  func addOrEditWalletAddress(_ address: WalletAddressEntity)
  func removeWalletAddress(id: String)
  
  func update(firstName: String?)
  func update(lastName: String?)
  func update(phone: String?)
  func update(email: String?)
  func update(fullName: String?)
  func update(addressEntity: AddressEntity?)
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
  func update(userID: String?)
  func update(referralLink: String?)
  func stored(phone: String)
  func stored(sessionID: String)
  func clearUserSession()
  func storeUser(user: LFUser)
}

extension AccountDataStorageProtocol {
  
  func storeWalletAddresses(_ addresses: [WalletAddressEntity]) {
  }
  
  func addOrEditWalletAddress(_ address: WalletAddressEntity) {
  }
}

public protocol UserInfomationDataProtocol {
  var userID: String? { get set }
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
  var referralLink: String? { get set }
  var userRewardType: String? { get set }
  var userAccessLevel: String? { get set }
  var userSelectedFundraiserID: String? { get set }
  var userRoundUpEnabled: Bool? { get set }
  var accountReviewStatus: String? { get set }
}
