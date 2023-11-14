// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain
import ZerohashDomain

public class MockAccountRepositoryProtocol: AccountRepositoryProtocol {

    public init() {}


    //MARK: - createZeroHashAccount

    public var createZeroHashAccountThrowableError: Error?
    public var createZeroHashAccountCallsCount = 0
    public var createZeroHashAccountCalled: Bool {
        return createZeroHashAccountCallsCount > 0
    }
    public var createZeroHashAccountReturnValue: ZeroHashAccount!
    public var createZeroHashAccountClosure: (() async throws -> ZeroHashAccount)?

    public func createZeroHashAccount() async throws -> ZeroHashAccount {
        if let error = createZeroHashAccountThrowableError {
            throw error
        }
        createZeroHashAccountCallsCount += 1
        if let createZeroHashAccountClosure = createZeroHashAccountClosure {
            return try await createZeroHashAccountClosure()
        } else {
            return createZeroHashAccountReturnValue
        }
    }

    //MARK: - getUser

    public var getUserThrowableError: Error?
    public var getUserCallsCount = 0
    public var getUserCalled: Bool {
        return getUserCallsCount > 0
    }
    public var getUserReturnValue: LFUser!
    public var getUserClosure: (() async throws -> LFUser)?

    public func getUser() async throws -> LFUser {
        if let error = getUserThrowableError {
            throw error
        }
        getUserCallsCount += 1
        if let getUserClosure = getUserClosure {
            return try await getUserClosure()
        } else {
            return getUserReturnValue
        }
    }

    //MARK: - getAvailableRewardCurrrencies

    public var getAvailableRewardCurrrenciesThrowableError: Error?
    public var getAvailableRewardCurrrenciesCallsCount = 0
    public var getAvailableRewardCurrrenciesCalled: Bool {
        return getAvailableRewardCurrrenciesCallsCount > 0
    }
    public var getAvailableRewardCurrrenciesReturnValue: AvailableRewardCurrenciesEntity!
    public var getAvailableRewardCurrrenciesClosure: (() async throws -> AvailableRewardCurrenciesEntity)?

    public func getAvailableRewardCurrrencies() async throws -> AvailableRewardCurrenciesEntity {
        if let error = getAvailableRewardCurrrenciesThrowableError {
            throw error
        }
        getAvailableRewardCurrrenciesCallsCount += 1
        if let getAvailableRewardCurrrenciesClosure = getAvailableRewardCurrrenciesClosure {
            return try await getAvailableRewardCurrrenciesClosure()
        } else {
            return getAvailableRewardCurrrenciesReturnValue
        }
    }

    //MARK: - getSelectedRewardCurrency

    public var getSelectedRewardCurrencyThrowableError: Error?
    public var getSelectedRewardCurrencyCallsCount = 0
    public var getSelectedRewardCurrencyCalled: Bool {
        return getSelectedRewardCurrencyCallsCount > 0
    }
    public var getSelectedRewardCurrencyReturnValue: RewardCurrencyEntity!
    public var getSelectedRewardCurrencyClosure: (() async throws -> RewardCurrencyEntity)?

    public func getSelectedRewardCurrency() async throws -> RewardCurrencyEntity {
        if let error = getSelectedRewardCurrencyThrowableError {
            throw error
        }
        getSelectedRewardCurrencyCallsCount += 1
        if let getSelectedRewardCurrencyClosure = getSelectedRewardCurrencyClosure {
            return try await getSelectedRewardCurrencyClosure()
        } else {
            return getSelectedRewardCurrencyReturnValue
        }
    }

    //MARK: - updateSelectedRewardCurrency

    public var updateSelectedRewardCurrencyRewardCurrencyThrowableError: Error?
    public var updateSelectedRewardCurrencyRewardCurrencyCallsCount = 0
    public var updateSelectedRewardCurrencyRewardCurrencyCalled: Bool {
        return updateSelectedRewardCurrencyRewardCurrencyCallsCount > 0
    }
    public var updateSelectedRewardCurrencyRewardCurrencyReceivedRewardCurrency: String?
    public var updateSelectedRewardCurrencyRewardCurrencyReceivedInvocations: [String] = []
    public var updateSelectedRewardCurrencyRewardCurrencyReturnValue: RewardCurrencyEntity!
    public var updateSelectedRewardCurrencyRewardCurrencyClosure: ((String) async throws -> RewardCurrencyEntity)?

    public func updateSelectedRewardCurrency(rewardCurrency: String) async throws -> RewardCurrencyEntity {
        if let error = updateSelectedRewardCurrencyRewardCurrencyThrowableError {
            throw error
        }
        updateSelectedRewardCurrencyRewardCurrencyCallsCount += 1
        updateSelectedRewardCurrencyRewardCurrencyReceivedRewardCurrency = rewardCurrency
        updateSelectedRewardCurrencyRewardCurrencyReceivedInvocations.append(rewardCurrency)
        if let updateSelectedRewardCurrencyRewardCurrencyClosure = updateSelectedRewardCurrencyRewardCurrencyClosure {
            return try await updateSelectedRewardCurrencyRewardCurrencyClosure(rewardCurrency)
        } else {
            return updateSelectedRewardCurrencyRewardCurrencyReturnValue
        }
    }

    //MARK: - getTransactions

    public var getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetThrowableError: Error?
    public var getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetCallsCount = 0
    public var getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetCalled: Bool {
        return getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetCallsCount > 0
    }
    public var getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetReceivedArguments: (accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int)?
    public var getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetReceivedInvocations: [(accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int)] = []
    public var getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetReturnValue: TransactionListEntity!
    public var getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetClosure: ((String, String, String, Int, Int) async throws -> TransactionListEntity)?

    public func getTransactions(accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int) async throws -> TransactionListEntity {
        if let error = getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetThrowableError {
            throw error
        }
        getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetCallsCount += 1
        getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetReceivedArguments = (accountId: accountId, currencyType: currencyType, transactionTypes: transactionTypes, limit: limit, offset: offset)
        getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetReceivedInvocations.append((accountId: accountId, currencyType: currencyType, transactionTypes: transactionTypes, limit: limit, offset: offset))
        if let getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetClosure = getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetClosure {
            return try await getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetClosure(accountId, currencyType, transactionTypes, limit, offset)
        } else {
            return getTransactionsAccountIdCurrencyTypeTransactionTypesLimitOffsetReturnValue
        }
    }

    //MARK: - getTransactionDetail

    public var getTransactionDetailAccountIdTransactionIdThrowableError: Error?
    public var getTransactionDetailAccountIdTransactionIdCallsCount = 0
    public var getTransactionDetailAccountIdTransactionIdCalled: Bool {
        return getTransactionDetailAccountIdTransactionIdCallsCount > 0
    }
    public var getTransactionDetailAccountIdTransactionIdReceivedArguments: (accountId: String, transactionId: String)?
    public var getTransactionDetailAccountIdTransactionIdReceivedInvocations: [(accountId: String, transactionId: String)] = []
    public var getTransactionDetailAccountIdTransactionIdReturnValue: TransactionEntity!
    public var getTransactionDetailAccountIdTransactionIdClosure: ((String, String) async throws -> TransactionEntity)?

    public func getTransactionDetail(accountId: String, transactionId: String) async throws -> TransactionEntity {
        if let error = getTransactionDetailAccountIdTransactionIdThrowableError {
            throw error
        }
        getTransactionDetailAccountIdTransactionIdCallsCount += 1
        getTransactionDetailAccountIdTransactionIdReceivedArguments = (accountId: accountId, transactionId: transactionId)
        getTransactionDetailAccountIdTransactionIdReceivedInvocations.append((accountId: accountId, transactionId: transactionId))
        if let getTransactionDetailAccountIdTransactionIdClosure = getTransactionDetailAccountIdTransactionIdClosure {
            return try await getTransactionDetailAccountIdTransactionIdClosure(accountId, transactionId)
        } else {
            return getTransactionDetailAccountIdTransactionIdReturnValue
        }
    }

    //MARK: - logout

    public var logoutThrowableError: Error?
    public var logoutCallsCount = 0
    public var logoutCalled: Bool {
        return logoutCallsCount > 0
    }
    public var logoutReturnValue: Bool!
    public var logoutClosure: (() async throws -> Bool)?

    public func logout() async throws -> Bool {
        if let error = logoutThrowableError {
            throw error
        }
        logoutCallsCount += 1
        if let logoutClosure = logoutClosure {
            return try await logoutClosure()
        } else {
            return logoutReturnValue
        }
    }

    //MARK: - createWalletAddresses

    public var createWalletAddressesAccountIdAddressNicknameThrowableError: Error?
    public var createWalletAddressesAccountIdAddressNicknameCallsCount = 0
    public var createWalletAddressesAccountIdAddressNicknameCalled: Bool {
        return createWalletAddressesAccountIdAddressNicknameCallsCount > 0
    }
    public var createWalletAddressesAccountIdAddressNicknameReceivedArguments: (accountId: String, address: String, nickname: String)?
    public var createWalletAddressesAccountIdAddressNicknameReceivedInvocations: [(accountId: String, address: String, nickname: String)] = []
    public var createWalletAddressesAccountIdAddressNicknameReturnValue: WalletAddressEntity!
    public var createWalletAddressesAccountIdAddressNicknameClosure: ((String, String, String) async throws -> WalletAddressEntity)?

    public func createWalletAddresses(accountId: String, address: String, nickname: String) async throws -> WalletAddressEntity {
        if let error = createWalletAddressesAccountIdAddressNicknameThrowableError {
            throw error
        }
        createWalletAddressesAccountIdAddressNicknameCallsCount += 1
        createWalletAddressesAccountIdAddressNicknameReceivedArguments = (accountId: accountId, address: address, nickname: nickname)
        createWalletAddressesAccountIdAddressNicknameReceivedInvocations.append((accountId: accountId, address: address, nickname: nickname))
        if let createWalletAddressesAccountIdAddressNicknameClosure = createWalletAddressesAccountIdAddressNicknameClosure {
            return try await createWalletAddressesAccountIdAddressNicknameClosure(accountId, address, nickname)
        } else {
            return createWalletAddressesAccountIdAddressNicknameReturnValue
        }
    }

    //MARK: - updateWalletAddresses

    public var updateWalletAddressesAccountIdWalletIdWalletAddressNicknameThrowableError: Error?
    public var updateWalletAddressesAccountIdWalletIdWalletAddressNicknameCallsCount = 0
    public var updateWalletAddressesAccountIdWalletIdWalletAddressNicknameCalled: Bool {
        return updateWalletAddressesAccountIdWalletIdWalletAddressNicknameCallsCount > 0
    }
    public var updateWalletAddressesAccountIdWalletIdWalletAddressNicknameReceivedArguments: (accountId: String, walletId: String, walletAddress: String, nickname: String)?
    public var updateWalletAddressesAccountIdWalletIdWalletAddressNicknameReceivedInvocations: [(accountId: String, walletId: String, walletAddress: String, nickname: String)] = []
    public var updateWalletAddressesAccountIdWalletIdWalletAddressNicknameReturnValue: WalletAddressEntity!
    public var updateWalletAddressesAccountIdWalletIdWalletAddressNicknameClosure: ((String, String, String, String) async throws -> WalletAddressEntity)?

    public func updateWalletAddresses(accountId: String, walletId: String, walletAddress: String, nickname: String) async throws -> WalletAddressEntity {
        if let error = updateWalletAddressesAccountIdWalletIdWalletAddressNicknameThrowableError {
            throw error
        }
        updateWalletAddressesAccountIdWalletIdWalletAddressNicknameCallsCount += 1
        updateWalletAddressesAccountIdWalletIdWalletAddressNicknameReceivedArguments = (accountId: accountId, walletId: walletId, walletAddress: walletAddress, nickname: nickname)
        updateWalletAddressesAccountIdWalletIdWalletAddressNicknameReceivedInvocations.append((accountId: accountId, walletId: walletId, walletAddress: walletAddress, nickname: nickname))
        if let updateWalletAddressesAccountIdWalletIdWalletAddressNicknameClosure = updateWalletAddressesAccountIdWalletIdWalletAddressNicknameClosure {
            return try await updateWalletAddressesAccountIdWalletIdWalletAddressNicknameClosure(accountId, walletId, walletAddress, nickname)
        } else {
            return updateWalletAddressesAccountIdWalletIdWalletAddressNicknameReturnValue
        }
    }

    //MARK: - getWalletAddresses

    public var getWalletAddressesAccountIdThrowableError: Error?
    public var getWalletAddressesAccountIdCallsCount = 0
    public var getWalletAddressesAccountIdCalled: Bool {
        return getWalletAddressesAccountIdCallsCount > 0
    }
    public var getWalletAddressesAccountIdReceivedAccountId: String?
    public var getWalletAddressesAccountIdReceivedInvocations: [String] = []
    public var getWalletAddressesAccountIdReturnValue: [WalletAddressEntity]!
    public var getWalletAddressesAccountIdClosure: ((String) async throws -> [WalletAddressEntity])?

    public func getWalletAddresses(accountId: String) async throws -> [WalletAddressEntity] {
        if let error = getWalletAddressesAccountIdThrowableError {
            throw error
        }
        getWalletAddressesAccountIdCallsCount += 1
        getWalletAddressesAccountIdReceivedAccountId = accountId
        getWalletAddressesAccountIdReceivedInvocations.append(accountId)
        if let getWalletAddressesAccountIdClosure = getWalletAddressesAccountIdClosure {
            return try await getWalletAddressesAccountIdClosure(accountId)
        } else {
            return getWalletAddressesAccountIdReturnValue
        }
    }

    //MARK: - deleteWalletAddresses

    public var deleteWalletAddressesAccountIdWalletAddressThrowableError: Error?
    public var deleteWalletAddressesAccountIdWalletAddressCallsCount = 0
    public var deleteWalletAddressesAccountIdWalletAddressCalled: Bool {
        return deleteWalletAddressesAccountIdWalletAddressCallsCount > 0
    }
    public var deleteWalletAddressesAccountIdWalletAddressReceivedArguments: (accountId: String, walletAddress: String)?
    public var deleteWalletAddressesAccountIdWalletAddressReceivedInvocations: [(accountId: String, walletAddress: String)] = []
    public var deleteWalletAddressesAccountIdWalletAddressReturnValue: DeleteWalletEntity!
    public var deleteWalletAddressesAccountIdWalletAddressClosure: ((String, String) async throws -> DeleteWalletEntity)?

    public func deleteWalletAddresses(accountId: String, walletAddress: String) async throws -> DeleteWalletEntity {
        if let error = deleteWalletAddressesAccountIdWalletAddressThrowableError {
            throw error
        }
        deleteWalletAddressesAccountIdWalletAddressCallsCount += 1
        deleteWalletAddressesAccountIdWalletAddressReceivedArguments = (accountId: accountId, walletAddress: walletAddress)
        deleteWalletAddressesAccountIdWalletAddressReceivedInvocations.append((accountId: accountId, walletAddress: walletAddress))
        if let deleteWalletAddressesAccountIdWalletAddressClosure = deleteWalletAddressesAccountIdWalletAddressClosure {
            return try await deleteWalletAddressesAccountIdWalletAddressClosure(accountId, walletAddress)
        } else {
            return deleteWalletAddressesAccountIdWalletAddressReturnValue
        }
    }

    //MARK: - getReferralCampaign

    public var getReferralCampaignThrowableError: Error?
    public var getReferralCampaignCallsCount = 0
    public var getReferralCampaignCalled: Bool {
        return getReferralCampaignCallsCount > 0
    }
    public var getReferralCampaignReturnValue: ReferralCampaignEntity!
    public var getReferralCampaignClosure: (() async throws -> ReferralCampaignEntity)?

    public func getReferralCampaign() async throws -> ReferralCampaignEntity {
        if let error = getReferralCampaignThrowableError {
            throw error
        }
        getReferralCampaignCallsCount += 1
        if let getReferralCampaignClosure = getReferralCampaignClosure {
            return try await getReferralCampaignClosure()
        } else {
            return getReferralCampaignReturnValue
        }
    }

    //MARK: - getTaxFile

    public var getTaxFileAccountIdThrowableError: Error?
    public var getTaxFileAccountIdCallsCount = 0
    public var getTaxFileAccountIdCalled: Bool {
        return getTaxFileAccountIdCallsCount > 0
    }
    public var getTaxFileAccountIdReceivedAccountId: String?
    public var getTaxFileAccountIdReceivedInvocations: [String] = []
    public var getTaxFileAccountIdReturnValue: [any TaxFileEntity]!
    public var getTaxFileAccountIdClosure: ((String) async throws -> [any TaxFileEntity])?

    public func getTaxFile(accountId: String) async throws -> [any TaxFileEntity] {
        if let error = getTaxFileAccountIdThrowableError {
            throw error
        }
        getTaxFileAccountIdCallsCount += 1
        getTaxFileAccountIdReceivedAccountId = accountId
        getTaxFileAccountIdReceivedInvocations.append(accountId)
        if let getTaxFileAccountIdClosure = getTaxFileAccountIdClosure {
            return try await getTaxFileAccountIdClosure(accountId)
        } else {
            return getTaxFileAccountIdReturnValue
        }
    }

    //MARK: - getTaxFileYear

    public var getTaxFileYearAccountIdYearFileNameThrowableError: Error?
    public var getTaxFileYearAccountIdYearFileNameCallsCount = 0
    public var getTaxFileYearAccountIdYearFileNameCalled: Bool {
        return getTaxFileYearAccountIdYearFileNameCallsCount > 0
    }
    public var getTaxFileYearAccountIdYearFileNameReceivedArguments: (accountId: String, year: String, fileName: String)?
    public var getTaxFileYearAccountIdYearFileNameReceivedInvocations: [(accountId: String, year: String, fileName: String)] = []
    public var getTaxFileYearAccountIdYearFileNameReturnValue: URL!
    public var getTaxFileYearAccountIdYearFileNameClosure: ((String, String, String) async throws -> URL)?

    public func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL {
        if let error = getTaxFileYearAccountIdYearFileNameThrowableError {
            throw error
        }
        getTaxFileYearAccountIdYearFileNameCallsCount += 1
        getTaxFileYearAccountIdYearFileNameReceivedArguments = (accountId: accountId, year: year, fileName: fileName)
        getTaxFileYearAccountIdYearFileNameReceivedInvocations.append((accountId: accountId, year: year, fileName: fileName))
        if let getTaxFileYearAccountIdYearFileNameClosure = getTaxFileYearAccountIdYearFileNameClosure {
            return try await getTaxFileYearAccountIdYearFileNameClosure(accountId, year, fileName)
        } else {
            return getTaxFileYearAccountIdYearFileNameReturnValue
        }
    }

    //MARK: - addToWaitList

    public var addToWaitListWaitListThrowableError: Error?
    public var addToWaitListWaitListCallsCount = 0
    public var addToWaitListWaitListCalled: Bool {
        return addToWaitListWaitListCallsCount > 0
    }
    public var addToWaitListWaitListReceivedWaitList: String?
    public var addToWaitListWaitListReceivedInvocations: [String] = []
    public var addToWaitListWaitListReturnValue: Bool!
    public var addToWaitListWaitListClosure: ((String) async throws -> Bool)?

    public func addToWaitList(waitList: String) async throws -> Bool {
        if let error = addToWaitListWaitListThrowableError {
            throw error
        }
        addToWaitListWaitListCallsCount += 1
        addToWaitListWaitListReceivedWaitList = waitList
        addToWaitListWaitListReceivedInvocations.append(waitList)
        if let addToWaitListWaitListClosure = addToWaitListWaitListClosure {
            return try await addToWaitListWaitListClosure(waitList)
        } else {
            return addToWaitListWaitListReturnValue
        }
    }

    //MARK: - getUserRewards

    public var getUserRewardsThrowableError: Error?
    public var getUserRewardsCallsCount = 0
    public var getUserRewardsCalled: Bool {
        return getUserRewardsCallsCount > 0
    }
    public var getUserRewardsReturnValue: [UserRewardsEntity]!
    public var getUserRewardsClosure: (() async throws -> [UserRewardsEntity])?

    public func getUserRewards() async throws -> [UserRewardsEntity] {
        if let error = getUserRewardsThrowableError {
            throw error
        }
        getUserRewardsCallsCount += 1
        if let getUserRewardsClosure = getUserRewardsClosure {
            return try await getUserRewardsClosure()
        } else {
            return getUserRewardsReturnValue
        }
    }

    //MARK: - getFeatureConfig

    public var getFeatureConfigThrowableError: Error?
    public var getFeatureConfigCallsCount = 0
    public var getFeatureConfigCalled: Bool {
        return getFeatureConfigCallsCount > 0
    }
    public var getFeatureConfigReturnValue: AccountFeatureConfigEntity!
    public var getFeatureConfigClosure: (() async throws -> AccountFeatureConfigEntity)?

    public func getFeatureConfig() async throws -> AccountFeatureConfigEntity {
        if let error = getFeatureConfigThrowableError {
            throw error
        }
        getFeatureConfigCallsCount += 1
        if let getFeatureConfigClosure = getFeatureConfigClosure {
            return try await getFeatureConfigClosure()
        } else {
            return getFeatureConfigReturnValue
        }
    }

    //MARK: - createSupportTicket

    public var createSupportTicketTitleDescriptionTypeThrowableError: Error?
    public var createSupportTicketTitleDescriptionTypeCallsCount = 0
    public var createSupportTicketTitleDescriptionTypeCalled: Bool {
        return createSupportTicketTitleDescriptionTypeCallsCount > 0
    }
    public var createSupportTicketTitleDescriptionTypeReceivedArguments: (title: String?, description: String?, type: String)?
    public var createSupportTicketTitleDescriptionTypeReceivedInvocations: [(title: String?, description: String?, type: String)] = []
    public var createSupportTicketTitleDescriptionTypeReturnValue: SupportTicketEntity!
    public var createSupportTicketTitleDescriptionTypeClosure: ((String?, String?, String) async throws -> SupportTicketEntity)?

    public func createSupportTicket(title: String?, description: String?, type: String) async throws -> SupportTicketEntity {
        if let error = createSupportTicketTitleDescriptionTypeThrowableError {
            throw error
        }
        createSupportTicketTitleDescriptionTypeCallsCount += 1
        createSupportTicketTitleDescriptionTypeReceivedArguments = (title: title, description: description, type: type)
        createSupportTicketTitleDescriptionTypeReceivedInvocations.append((title: title, description: description, type: type))
        if let createSupportTicketTitleDescriptionTypeClosure = createSupportTicketTitleDescriptionTypeClosure {
            return try await createSupportTicketTitleDescriptionTypeClosure(title, description, type)
        } else {
            return createSupportTicketTitleDescriptionTypeReturnValue
        }
    }

}
