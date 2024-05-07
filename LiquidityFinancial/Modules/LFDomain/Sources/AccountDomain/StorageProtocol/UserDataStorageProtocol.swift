import Foundation
import NetspendDomain
import Combine
import AccountService
import RainDomain

// sourcery: AutoMockable
public protocol AccountDataStorageProtocol {
  var userInfomationData: UserInfomationDataProtocol { get }
  var phoneNumber: String { get }
  var sessionID: String { get }
  var userNameDisplay: String { get set }
  var userEmail: String { get set }
  var addressDetail: String { get }
  var fiatAccountID: String? { get set }
  var cryptoAccountID: String? { get set }
  var externalAccountID: String? { get set }
  var userCompleteOnboarding: Bool { get set }
  var isBiometricUsageEnabled: Bool { get set }
  
  func subscribeWalletAddressesChanged(_ completion: @escaping ([WalletAddressEntity]) -> Void) -> Cancellable
  func storeWalletAddresses(_ addresses: [WalletAddressEntity])
  func addOrEditWalletAddress(_ address: WalletAddressEntity)
  func removeWalletAddress(id: String)
  
  var smartContractsSubject: CurrentValueSubject<[RainSmartContractEntity], Never> { get }
  var smartContracts: [RainSmartContractEntity] { get }
  func subscribeSmartContractsChanged(_ completion: @escaping ([RainSmartContractEntity]) -> Void) -> Cancellable
  func storeSmartContracts(_ smartContracts: [RainSmartContractEntity])
  
  func subscribeLinkedSourcesChanged(_ completion: @escaping ([any LinkedSourceDataEntity]) -> Void) -> Cancellable
  func storeLinkedSources(_ sources: [any LinkedSourceDataEntity])
  func addOrEditLinkedSource(_ source: any LinkedSourceDataEntity)
  func removeLinkedSource(id: String)
  
  var availableRewardCurrenciesSubject: CurrentValueSubject<AvailableRewardCurrenciesEntity?, Never> { get }
  var selectedRewardCurrencySubject: CurrentValueSubject<RewardCurrencyEntity?, Never> { get }
  
  var accountsSubject: CurrentValueSubject<[AccountModel], Never> { get }
  var fiatAccounts: [AccountModel] { get }
  func addOrUpdateAccounts(_ accounts: [AccountModel])
  func addOrUpdateAccount(_ account: AccountModel)
  
  func update(firstName: String?)
  func update(lastName: String?)
  func update(phone: String?)
  func update(phoneVerified: Bool?)
  func update(email: String?)
  func update(emailVerified: Bool?)
  func update(mfaEnabled: Bool?)
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
  func update(missingSteps: [String]?)
  func stored(phone: String)
  func stored(sessionID: String)
  func clearUserSession()
  func storeUser(user: LFUser)
  
  var featureConfig: FeatureConfigModel? { get set }
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
  var phoneVerified: Bool? { get set }
  var email: String? { get set }
  var emailVerified: Bool? { get set }
  var mfaEnabled: Bool? { get set }
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
  var missingSteps: [String]? { get set }
}
