// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain
import Combine
import NetSpendDomain

public class MockAccountDataStorageProtocol: AccountDataStorageProtocol {

    public init() {}

    public var userInfomationData: UserInfomationDataProtocol {
        get { return underlyingUserInfomationData }
        set(value) { underlyingUserInfomationData = value }
    }
    public var underlyingUserInfomationData: UserInfomationDataProtocol!
    public var phoneNumber: String {
        get { return underlyingPhoneNumber }
        set(value) { underlyingPhoneNumber = value }
    }
    public var underlyingPhoneNumber: String!
    public var sessionID: String {
        get { return underlyingSessionID }
        set(value) { underlyingSessionID = value }
    }
    public var underlyingSessionID: String!
    public var userNameDisplay: String {
        get { return underlyingUserNameDisplay }
        set(value) { underlyingUserNameDisplay = value }
    }
    public var underlyingUserNameDisplay: String!
    public var userEmail: String {
        get { return underlyingUserEmail }
        set(value) { underlyingUserEmail = value }
    }
    public var underlyingUserEmail: String!
    public var addressDetail: String {
        get { return underlyingAddressDetail }
        set(value) { underlyingAddressDetail = value }
    }
    public var underlyingAddressDetail: String!
    public var fiatAccountID: String?
    public var cryptoAccountID: String?
    public var externalAccountID: String?
    public var userCompleteOnboarding: Bool {
        get { return underlyingUserCompleteOnboarding }
        set(value) { underlyingUserCompleteOnboarding = value }
    }
    public var underlyingUserCompleteOnboarding: Bool!
    public var availableRewardCurrenciesSubject: CurrentValueSubject<AvailableRewardCurrenciesEntity?, Never> {
        get { return underlyingAvailableRewardCurrenciesSubject }
        set(value) { underlyingAvailableRewardCurrenciesSubject = value }
    }
    public var underlyingAvailableRewardCurrenciesSubject: CurrentValueSubject<AvailableRewardCurrenciesEntity?, Never>!
    public var selectedRewardCurrencySubject: CurrentValueSubject<RewardCurrencyEntity?, Never> {
        get { return underlyingSelectedRewardCurrencySubject }
        set(value) { underlyingSelectedRewardCurrencySubject = value }
    }
    public var underlyingSelectedRewardCurrencySubject: CurrentValueSubject<RewardCurrencyEntity?, Never>!
    public var accountsSubject: CurrentValueSubject<[LFAccount], Never> {
        get { return underlyingAccountsSubject }
        set(value) { underlyingAccountsSubject = value }
    }
    public var underlyingAccountsSubject: CurrentValueSubject<[LFAccount], Never>!
    public var featureConfig: FeatureConfigModel?

    //MARK: - subscribeWalletAddressesChanged

    public var subscribeWalletAddressesChangedCallsCount = 0
    public var subscribeWalletAddressesChangedCalled: Bool {
        return subscribeWalletAddressesChangedCallsCount > 0
    }
    public var subscribeWalletAddressesChangedReceivedCompletion: (([WalletAddressEntity]) -> Void)?
    public var subscribeWalletAddressesChangedReceivedInvocations: [(([WalletAddressEntity]) -> Void)] = []
    public var subscribeWalletAddressesChangedReturnValue: Cancellable!
    public var subscribeWalletAddressesChangedClosure: ((@escaping ([WalletAddressEntity]) -> Void) -> Cancellable)?

    public func subscribeWalletAddressesChanged(_ completion: @escaping ([WalletAddressEntity]) -> Void) -> Cancellable {
        subscribeWalletAddressesChangedCallsCount += 1
        subscribeWalletAddressesChangedReceivedCompletion = completion
        subscribeWalletAddressesChangedReceivedInvocations.append(completion)
        if let subscribeWalletAddressesChangedClosure = subscribeWalletAddressesChangedClosure {
            return subscribeWalletAddressesChangedClosure(completion)
        } else {
            return subscribeWalletAddressesChangedReturnValue
        }
    }

    //MARK: - storeWalletAddresses

    public var storeWalletAddressesCallsCount = 0
    public var storeWalletAddressesCalled: Bool {
        return storeWalletAddressesCallsCount > 0
    }
    public var storeWalletAddressesReceivedAddresses: [WalletAddressEntity]?
    public var storeWalletAddressesReceivedInvocations: [[WalletAddressEntity]] = []
    public var storeWalletAddressesClosure: (([WalletAddressEntity]) -> Void)?

    public func storeWalletAddresses(_ addresses: [WalletAddressEntity]) {
        storeWalletAddressesCallsCount += 1
        storeWalletAddressesReceivedAddresses = addresses
        storeWalletAddressesReceivedInvocations.append(addresses)
        storeWalletAddressesClosure?(addresses)
    }

    //MARK: - addOrEditWalletAddress

    public var addOrEditWalletAddressCallsCount = 0
    public var addOrEditWalletAddressCalled: Bool {
        return addOrEditWalletAddressCallsCount > 0
    }
    public var addOrEditWalletAddressReceivedAddress: WalletAddressEntity?
    public var addOrEditWalletAddressReceivedInvocations: [WalletAddressEntity] = []
    public var addOrEditWalletAddressClosure: ((WalletAddressEntity) -> Void)?

    public func addOrEditWalletAddress(_ address: WalletAddressEntity) {
        addOrEditWalletAddressCallsCount += 1
        addOrEditWalletAddressReceivedAddress = address
        addOrEditWalletAddressReceivedInvocations.append(address)
        addOrEditWalletAddressClosure?(address)
    }

    //MARK: - removeWalletAddress

    public var removeWalletAddressIdCallsCount = 0
    public var removeWalletAddressIdCalled: Bool {
        return removeWalletAddressIdCallsCount > 0
    }
    public var removeWalletAddressIdReceivedId: String?
    public var removeWalletAddressIdReceivedInvocations: [String] = []
    public var removeWalletAddressIdClosure: ((String) -> Void)?

    public func removeWalletAddress(id: String) {
        removeWalletAddressIdCallsCount += 1
        removeWalletAddressIdReceivedId = id
        removeWalletAddressIdReceivedInvocations.append(id)
        removeWalletAddressIdClosure?(id)
    }

    //MARK: - subscribeLinkedSourcesChanged

    public var subscribeLinkedSourcesChangedCallsCount = 0
    public var subscribeLinkedSourcesChangedCalled: Bool {
        return subscribeLinkedSourcesChangedCallsCount > 0
    }
    public var subscribeLinkedSourcesChangedReceivedCompletion: (([any LinkedSourceDataEntity]) -> Void)?
    public var subscribeLinkedSourcesChangedReceivedInvocations: [(([any LinkedSourceDataEntity]) -> Void)] = []
    public var subscribeLinkedSourcesChangedReturnValue: Cancellable!
    public var subscribeLinkedSourcesChangedClosure: ((@escaping ([any LinkedSourceDataEntity]) -> Void) -> Cancellable)?

    public func subscribeLinkedSourcesChanged(_ completion: @escaping ([any LinkedSourceDataEntity]) -> Void) -> Cancellable {
        subscribeLinkedSourcesChangedCallsCount += 1
        subscribeLinkedSourcesChangedReceivedCompletion = completion
        subscribeLinkedSourcesChangedReceivedInvocations.append(completion)
        if let subscribeLinkedSourcesChangedClosure = subscribeLinkedSourcesChangedClosure {
            return subscribeLinkedSourcesChangedClosure(completion)
        } else {
            return subscribeLinkedSourcesChangedReturnValue
        }
    }

    //MARK: - storeLinkedSources

    public var storeLinkedSourcesCallsCount = 0
    public var storeLinkedSourcesCalled: Bool {
        return storeLinkedSourcesCallsCount > 0
    }
    public var storeLinkedSourcesReceivedSources: [any LinkedSourceDataEntity]?
    public var storeLinkedSourcesReceivedInvocations: [[any LinkedSourceDataEntity]] = []
    public var storeLinkedSourcesClosure: (([any LinkedSourceDataEntity]) -> Void)?

    public func storeLinkedSources(_ sources: [any LinkedSourceDataEntity]) {
        storeLinkedSourcesCallsCount += 1
        storeLinkedSourcesReceivedSources = sources
        storeLinkedSourcesReceivedInvocations.append(sources)
        storeLinkedSourcesClosure?(sources)
    }

    //MARK: - addOrEditLinkedSource

    public var addOrEditLinkedSourceCallsCount = 0
    public var addOrEditLinkedSourceCalled: Bool {
        return addOrEditLinkedSourceCallsCount > 0
    }
    public var addOrEditLinkedSourceReceivedSource: (any LinkedSourceDataEntity)?
    public var addOrEditLinkedSourceReceivedInvocations: [any LinkedSourceDataEntity] = []
    public var addOrEditLinkedSourceClosure: ((any LinkedSourceDataEntity) -> Void)?

    public func addOrEditLinkedSource(_ source: any LinkedSourceDataEntity) {
        addOrEditLinkedSourceCallsCount += 1
        addOrEditLinkedSourceReceivedSource = source
        addOrEditLinkedSourceReceivedInvocations.append(source)
        addOrEditLinkedSourceClosure?(source)
    }

    //MARK: - removeLinkedSource

    public var removeLinkedSourceIdCallsCount = 0
    public var removeLinkedSourceIdCalled: Bool {
        return removeLinkedSourceIdCallsCount > 0
    }
    public var removeLinkedSourceIdReceivedId: String?
    public var removeLinkedSourceIdReceivedInvocations: [String] = []
    public var removeLinkedSourceIdClosure: ((String) -> Void)?

    public func removeLinkedSource(id: String) {
        removeLinkedSourceIdCallsCount += 1
        removeLinkedSourceIdReceivedId = id
        removeLinkedSourceIdReceivedInvocations.append(id)
        removeLinkedSourceIdClosure?(id)
    }

    //MARK: - addOrUpdateAccounts

    public var addOrUpdateAccountsCallsCount = 0
    public var addOrUpdateAccountsCalled: Bool {
        return addOrUpdateAccountsCallsCount > 0
    }
    public var addOrUpdateAccountsReceivedAccounts: [LFAccount]?
    public var addOrUpdateAccountsReceivedInvocations: [[LFAccount]] = []
    public var addOrUpdateAccountsClosure: (([LFAccount]) -> Void)?

    public func addOrUpdateAccounts(_ accounts: [LFAccount]) {
        addOrUpdateAccountsCallsCount += 1
        addOrUpdateAccountsReceivedAccounts = accounts
        addOrUpdateAccountsReceivedInvocations.append(accounts)
        addOrUpdateAccountsClosure?(accounts)
    }

    //MARK: - addOrUpdateAccount

    public var addOrUpdateAccountCallsCount = 0
    public var addOrUpdateAccountCalled: Bool {
        return addOrUpdateAccountCallsCount > 0
    }
    public var addOrUpdateAccountReceivedAccount: LFAccount?
    public var addOrUpdateAccountReceivedInvocations: [LFAccount] = []
    public var addOrUpdateAccountClosure: ((LFAccount) -> Void)?

    public func addOrUpdateAccount(_ account: LFAccount) {
        addOrUpdateAccountCallsCount += 1
        addOrUpdateAccountReceivedAccount = account
        addOrUpdateAccountReceivedInvocations.append(account)
        addOrUpdateAccountClosure?(account)
    }

    //MARK: - update

    public var updateFirstNameCallsCount = 0
    public var updateFirstNameCalled: Bool {
        return updateFirstNameCallsCount > 0
    }
    public var updateFirstNameReceivedFirstName: String?
    public var updateFirstNameReceivedInvocations: [String?] = []
    public var updateFirstNameClosure: ((String?) -> Void)?

    public func update(firstName: String?) {
        updateFirstNameCallsCount += 1
        updateFirstNameReceivedFirstName = firstName
        updateFirstNameReceivedInvocations.append(firstName)
        updateFirstNameClosure?(firstName)
    }

    //MARK: - update

    public var updateLastNameCallsCount = 0
    public var updateLastNameCalled: Bool {
        return updateLastNameCallsCount > 0
    }
    public var updateLastNameReceivedLastName: String?
    public var updateLastNameReceivedInvocations: [String?] = []
    public var updateLastNameClosure: ((String?) -> Void)?

    public func update(lastName: String?) {
        updateLastNameCallsCount += 1
        updateLastNameReceivedLastName = lastName
        updateLastNameReceivedInvocations.append(lastName)
        updateLastNameClosure?(lastName)
    }

    //MARK: - update

    public var updatePhoneCallsCount = 0
    public var updatePhoneCalled: Bool {
        return updatePhoneCallsCount > 0
    }
    public var updatePhoneReceivedPhone: String?
    public var updatePhoneReceivedInvocations: [String?] = []
    public var updatePhoneClosure: ((String?) -> Void)?

    public func update(phone: String?) {
        updatePhoneCallsCount += 1
        updatePhoneReceivedPhone = phone
        updatePhoneReceivedInvocations.append(phone)
        updatePhoneClosure?(phone)
    }

    //MARK: - update

    public var updateEmailCallsCount = 0
    public var updateEmailCalled: Bool {
        return updateEmailCallsCount > 0
    }
    public var updateEmailReceivedEmail: String?
    public var updateEmailReceivedInvocations: [String?] = []
    public var updateEmailClosure: ((String?) -> Void)?

    public func update(email: String?) {
        updateEmailCallsCount += 1
        updateEmailReceivedEmail = email
        updateEmailReceivedInvocations.append(email)
        updateEmailClosure?(email)
    }

    //MARK: - update

    public var updateFullNameCallsCount = 0
    public var updateFullNameCalled: Bool {
        return updateFullNameCallsCount > 0
    }
    public var updateFullNameReceivedFullName: String?
    public var updateFullNameReceivedInvocations: [String?] = []
    public var updateFullNameClosure: ((String?) -> Void)?

    public func update(fullName: String?) {
        updateFullNameCallsCount += 1
        updateFullNameReceivedFullName = fullName
        updateFullNameReceivedInvocations.append(fullName)
        updateFullNameClosure?(fullName)
    }

    //MARK: - update

    public var updateAddressEntityCallsCount = 0
    public var updateAddressEntityCalled: Bool {
        return updateAddressEntityCallsCount > 0
    }
    public var updateAddressEntityReceivedAddressEntity: AddressEntity?
    public var updateAddressEntityReceivedInvocations: [AddressEntity?] = []
    public var updateAddressEntityClosure: ((AddressEntity?) -> Void)?

    public func update(addressEntity: AddressEntity?) {
        updateAddressEntityCallsCount += 1
        updateAddressEntityReceivedAddressEntity = addressEntity
        updateAddressEntityReceivedInvocations.append(addressEntity)
        updateAddressEntityClosure?(addressEntity)
    }

    //MARK: - update

    public var updateDateOfBirthCallsCount = 0
    public var updateDateOfBirthCalled: Bool {
        return updateDateOfBirthCallsCount > 0
    }
    public var updateDateOfBirthReceivedDateOfBirth: String?
    public var updateDateOfBirthReceivedInvocations: [String?] = []
    public var updateDateOfBirthClosure: ((String?) -> Void)?

    public func update(dateOfBirth: String?) {
        updateDateOfBirthCallsCount += 1
        updateDateOfBirthReceivedDateOfBirth = dateOfBirth
        updateDateOfBirthReceivedInvocations.append(dateOfBirth)
        updateDateOfBirthClosure?(dateOfBirth)
    }

    //MARK: - update

    public var updateAddressLine1CallsCount = 0
    public var updateAddressLine1Called: Bool {
        return updateAddressLine1CallsCount > 0
    }
    public var updateAddressLine1ReceivedAddressLine1: String?
    public var updateAddressLine1ReceivedInvocations: [String?] = []
    public var updateAddressLine1Closure: ((String?) -> Void)?

    public func update(addressLine1: String?) {
        updateAddressLine1CallsCount += 1
        updateAddressLine1ReceivedAddressLine1 = addressLine1
        updateAddressLine1ReceivedInvocations.append(addressLine1)
        updateAddressLine1Closure?(addressLine1)
    }

    //MARK: - update

    public var updateAddressLine2CallsCount = 0
    public var updateAddressLine2Called: Bool {
        return updateAddressLine2CallsCount > 0
    }
    public var updateAddressLine2ReceivedAddressLine2: String?
    public var updateAddressLine2ReceivedInvocations: [String?] = []
    public var updateAddressLine2Closure: ((String?) -> Void)?

    public func update(addressLine2: String?) {
        updateAddressLine2CallsCount += 1
        updateAddressLine2ReceivedAddressLine2 = addressLine2
        updateAddressLine2ReceivedInvocations.append(addressLine2)
        updateAddressLine2Closure?(addressLine2)
    }

    //MARK: - update

    public var updateEncryptedDataCallsCount = 0
    public var updateEncryptedDataCalled: Bool {
        return updateEncryptedDataCallsCount > 0
    }
    public var updateEncryptedDataReceivedEncryptedData: String?
    public var updateEncryptedDataReceivedInvocations: [String?] = []
    public var updateEncryptedDataClosure: ((String?) -> Void)?

    public func update(encryptedData: String?) {
        updateEncryptedDataCallsCount += 1
        updateEncryptedDataReceivedEncryptedData = encryptedData
        updateEncryptedDataReceivedInvocations.append(encryptedData)
        updateEncryptedDataClosure?(encryptedData)
    }

    //MARK: - update

    public var updateSsnCallsCount = 0
    public var updateSsnCalled: Bool {
        return updateSsnCallsCount > 0
    }
    public var updateSsnReceivedSsn: String?
    public var updateSsnReceivedInvocations: [String?] = []
    public var updateSsnClosure: ((String?) -> Void)?

    public func update(ssn: String?) {
        updateSsnCallsCount += 1
        updateSsnReceivedSsn = ssn
        updateSsnReceivedInvocations.append(ssn)
        updateSsnClosure?(ssn)
    }

    //MARK: - update

    public var updatePassportCallsCount = 0
    public var updatePassportCalled: Bool {
        return updatePassportCallsCount > 0
    }
    public var updatePassportReceivedPassport: String?
    public var updatePassportReceivedInvocations: [String?] = []
    public var updatePassportClosure: ((String?) -> Void)?

    public func update(passport: String?) {
        updatePassportCallsCount += 1
        updatePassportReceivedPassport = passport
        updatePassportReceivedInvocations.append(passport)
        updatePassportClosure?(passport)
    }

    //MARK: - update

    public var updateCityCallsCount = 0
    public var updateCityCalled: Bool {
        return updateCityCallsCount > 0
    }
    public var updateCityReceivedCity: String?
    public var updateCityReceivedInvocations: [String?] = []
    public var updateCityClosure: ((String?) -> Void)?

    public func update(city: String?) {
        updateCityCallsCount += 1
        updateCityReceivedCity = city
        updateCityReceivedInvocations.append(city)
        updateCityClosure?(city)
    }

    //MARK: - update

    public var updateStateCallsCount = 0
    public var updateStateCalled: Bool {
        return updateStateCallsCount > 0
    }
    public var updateStateReceivedState: String?
    public var updateStateReceivedInvocations: [String?] = []
    public var updateStateClosure: ((String?) -> Void)?

    public func update(state: String?) {
        updateStateCallsCount += 1
        updateStateReceivedState = state
        updateStateReceivedInvocations.append(state)
        updateStateClosure?(state)
    }

    //MARK: - update

    public var updatePostalCodeCallsCount = 0
    public var updatePostalCodeCalled: Bool {
        return updatePostalCodeCallsCount > 0
    }
    public var updatePostalCodeReceivedPostalCode: String?
    public var updatePostalCodeReceivedInvocations: [String?] = []
    public var updatePostalCodeClosure: ((String?) -> Void)?

    public func update(postalCode: String?) {
        updatePostalCodeCallsCount += 1
        updatePostalCodeReceivedPostalCode = postalCode
        updatePostalCodeReceivedInvocations.append(postalCode)
        updatePostalCodeClosure?(postalCode)
    }

    //MARK: - update

    public var updateCountryCallsCount = 0
    public var updateCountryCalled: Bool {
        return updateCountryCallsCount > 0
    }
    public var updateCountryReceivedCountry: String?
    public var updateCountryReceivedInvocations: [String?] = []
    public var updateCountryClosure: ((String?) -> Void)?

    public func update(country: String?) {
        updateCountryCallsCount += 1
        updateCountryReceivedCountry = country
        updateCountryReceivedInvocations.append(country)
        updateCountryClosure?(country)
    }

    //MARK: - update

    public var updateUserIDCallsCount = 0
    public var updateUserIDCalled: Bool {
        return updateUserIDCallsCount > 0
    }
    public var updateUserIDReceivedUserID: String?
    public var updateUserIDReceivedInvocations: [String?] = []
    public var updateUserIDClosure: ((String?) -> Void)?

    public func update(userID: String?) {
        updateUserIDCallsCount += 1
        updateUserIDReceivedUserID = userID
        updateUserIDReceivedInvocations.append(userID)
        updateUserIDClosure?(userID)
    }

    //MARK: - update

    public var updateReferralLinkCallsCount = 0
    public var updateReferralLinkCalled: Bool {
        return updateReferralLinkCallsCount > 0
    }
    public var updateReferralLinkReceivedReferralLink: String?
    public var updateReferralLinkReceivedInvocations: [String?] = []
    public var updateReferralLinkClosure: ((String?) -> Void)?

    public func update(referralLink: String?) {
        updateReferralLinkCallsCount += 1
        updateReferralLinkReceivedReferralLink = referralLink
        updateReferralLinkReceivedInvocations.append(referralLink)
        updateReferralLinkClosure?(referralLink)
    }

    //MARK: - stored

    public var storedPhoneCallsCount = 0
    public var storedPhoneCalled: Bool {
        return storedPhoneCallsCount > 0
    }
    public var storedPhoneReceivedPhone: String?
    public var storedPhoneReceivedInvocations: [String] = []
    public var storedPhoneClosure: ((String) -> Void)?

    public func stored(phone: String) {
        storedPhoneCallsCount += 1
        storedPhoneReceivedPhone = phone
        storedPhoneReceivedInvocations.append(phone)
        storedPhoneClosure?(phone)
    }

    //MARK: - stored

    public var storedSessionIDCallsCount = 0
    public var storedSessionIDCalled: Bool {
        return storedSessionIDCallsCount > 0
    }
    public var storedSessionIDReceivedSessionID: String?
    public var storedSessionIDReceivedInvocations: [String] = []
    public var storedSessionIDClosure: ((String) -> Void)?

    public func stored(sessionID: String) {
        storedSessionIDCallsCount += 1
        storedSessionIDReceivedSessionID = sessionID
        storedSessionIDReceivedInvocations.append(sessionID)
        storedSessionIDClosure?(sessionID)
    }

    //MARK: - clearUserSession

    public var clearUserSessionCallsCount = 0
    public var clearUserSessionCalled: Bool {
        return clearUserSessionCallsCount > 0
    }
    public var clearUserSessionClosure: (() -> Void)?

    public func clearUserSession() {
        clearUserSessionCallsCount += 1
        clearUserSessionClosure?()
    }

    //MARK: - storeUser

    public var storeUserUserCallsCount = 0
    public var storeUserUserCalled: Bool {
        return storeUserUserCallsCount > 0
    }
    public var storeUserUserReceivedUser: LFUser?
    public var storeUserUserReceivedInvocations: [LFUser] = []
    public var storeUserUserClosure: ((LFUser) -> Void)?

    public func storeUser(user: LFUser) {
        storeUserUserCallsCount += 1
        storeUserUserReceivedUser = user
        storeUserUserReceivedInvocations.append(user)
        storeUserUserClosure?(user)
    }

}
