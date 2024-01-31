// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import ZerohashDomain
import AccountDomain

public class MockZerohashRepositoryProtocol: ZerohashRepositoryProtocol {

    public init() {}


    //MARK: - sendCrypto

    public var sendCryptoAccountIdDestinationAddressAmountThrowableError: Error?
    public var sendCryptoAccountIdDestinationAddressAmountCallsCount = 0
    public var sendCryptoAccountIdDestinationAddressAmountCalled: Bool {
        return sendCryptoAccountIdDestinationAddressAmountCallsCount > 0
    }
    public var sendCryptoAccountIdDestinationAddressAmountReceivedArguments: (accountId: String, destinationAddress: String, amount: Double)?
    public var sendCryptoAccountIdDestinationAddressAmountReceivedInvocations: [(accountId: String, destinationAddress: String, amount: Double)] = []
    public var sendCryptoAccountIdDestinationAddressAmountReturnValue: TransactionEntity!
    public var sendCryptoAccountIdDestinationAddressAmountClosure: ((String, String, Double) async throws -> TransactionEntity)?

    public func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity {
        if let error = sendCryptoAccountIdDestinationAddressAmountThrowableError {
            throw error
        }
        sendCryptoAccountIdDestinationAddressAmountCallsCount += 1
        sendCryptoAccountIdDestinationAddressAmountReceivedArguments = (accountId: accountId, destinationAddress: destinationAddress, amount: amount)
        sendCryptoAccountIdDestinationAddressAmountReceivedInvocations.append((accountId: accountId, destinationAddress: destinationAddress, amount: amount))
        if let sendCryptoAccountIdDestinationAddressAmountClosure = sendCryptoAccountIdDestinationAddressAmountClosure {
            return try await sendCryptoAccountIdDestinationAddressAmountClosure(accountId, destinationAddress, amount)
        } else {
            return sendCryptoAccountIdDestinationAddressAmountReturnValue
        }
    }

    //MARK: - lockedNetworkFee

    public var lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountThrowableError: Error?
    public var lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountCallsCount = 0
    public var lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountCalled: Bool {
        return lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountCallsCount > 0
    }
    public var lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountReceivedArguments: (accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool)?
    public var lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountReceivedInvocations: [(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool)] = []
    public var lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountReturnValue: APILockedNetworkFeeResponse!
    public var lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountClosure: ((String, String, Double, Bool) async throws -> APILockedNetworkFeeResponse)?

    public func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse {
        if let error = lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountThrowableError {
            throw error
        }
        lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountCallsCount += 1
        lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountReceivedArguments = (accountId: accountId, destinationAddress: destinationAddress, amount: amount, maxAmount: maxAmount)
        lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountReceivedInvocations.append((accountId: accountId, destinationAddress: destinationAddress, amount: amount, maxAmount: maxAmount))
        if let lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountClosure = lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountClosure {
            return try await lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountClosure(accountId, destinationAddress, amount, maxAmount)
        } else {
            return lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountReturnValue
        }
    }

    //MARK: - execute

    public var executeAccountIdQuoteIdThrowableError: Error?
    public var executeAccountIdQuoteIdCallsCount = 0
    public var executeAccountIdQuoteIdCalled: Bool {
        return executeAccountIdQuoteIdCallsCount > 0
    }
    public var executeAccountIdQuoteIdReceivedArguments: (accountId: String, quoteId: String)?
    public var executeAccountIdQuoteIdReceivedInvocations: [(accountId: String, quoteId: String)] = []
    public var executeAccountIdQuoteIdReturnValue: TransactionEntity!
    public var executeAccountIdQuoteIdClosure: ((String, String) async throws -> TransactionEntity)?

    public func execute(accountId: String, quoteId: String) async throws -> TransactionEntity {
        if let error = executeAccountIdQuoteIdThrowableError {
            throw error
        }
        executeAccountIdQuoteIdCallsCount += 1
        executeAccountIdQuoteIdReceivedArguments = (accountId: accountId, quoteId: quoteId)
        executeAccountIdQuoteIdReceivedInvocations.append((accountId: accountId, quoteId: quoteId))
        if let executeAccountIdQuoteIdClosure = executeAccountIdQuoteIdClosure {
            return try await executeAccountIdQuoteIdClosure(accountId, quoteId)
        } else {
            return executeAccountIdQuoteIdReturnValue
        }
    }

    //MARK: - getOnboardingStep

    public var getOnboardingStepThrowableError: Error?
    public var getOnboardingStepCallsCount = 0
    public var getOnboardingStepCalled: Bool {
        return getOnboardingStepCallsCount > 0
    }
    public var getOnboardingStepReturnValue: ZHOnboardingStepEntity!
    public var getOnboardingStepClosure: (() async throws -> ZHOnboardingStepEntity)?

    public func getOnboardingStep() async throws -> ZHOnboardingStepEntity {
        if let error = getOnboardingStepThrowableError {
            throw error
        }
        getOnboardingStepCallsCount += 1
        if let getOnboardingStepClosure = getOnboardingStepClosure {
            return try await getOnboardingStepClosure()
        } else {
            return getOnboardingStepReturnValue
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

    //MARK: - sellCrypto

    public var sellCryptoAccountIdQuoteIdThrowableError: Error?
    public var sellCryptoAccountIdQuoteIdCallsCount = 0
    public var sellCryptoAccountIdQuoteIdCalled: Bool {
        return sellCryptoAccountIdQuoteIdCallsCount > 0
    }
    public var sellCryptoAccountIdQuoteIdReceivedArguments: (accountId: String, quoteId: String)?
    public var sellCryptoAccountIdQuoteIdReceivedInvocations: [(accountId: String, quoteId: String)] = []
    public var sellCryptoAccountIdQuoteIdReturnValue: SellCryptoEntity!
    public var sellCryptoAccountIdQuoteIdClosure: ((String, String) async throws -> SellCryptoEntity)?

    public func sellCrypto(accountId: String, quoteId: String) async throws -> SellCryptoEntity {
        if let error = sellCryptoAccountIdQuoteIdThrowableError {
            throw error
        }
        sellCryptoAccountIdQuoteIdCallsCount += 1
        sellCryptoAccountIdQuoteIdReceivedArguments = (accountId: accountId, quoteId: quoteId)
        sellCryptoAccountIdQuoteIdReceivedInvocations.append((accountId: accountId, quoteId: quoteId))
        if let sellCryptoAccountIdQuoteIdClosure = sellCryptoAccountIdQuoteIdClosure {
            return try await sellCryptoAccountIdQuoteIdClosure(accountId, quoteId)
        } else {
            return sellCryptoAccountIdQuoteIdReturnValue
        }
    }

    //MARK: - getSellQuote

    public var getSellQuoteAccountIdAmountQuantityThrowableError: Error?
    public var getSellQuoteAccountIdAmountQuantityCallsCount = 0
    public var getSellQuoteAccountIdAmountQuantityCalled: Bool {
        return getSellQuoteAccountIdAmountQuantityCallsCount > 0
    }
    public var getSellQuoteAccountIdAmountQuantityReceivedArguments: (accountId: String, amount: String?, quantity: String?)?
    public var getSellQuoteAccountIdAmountQuantityReceivedInvocations: [(accountId: String, amount: String?, quantity: String?)] = []
    public var getSellQuoteAccountIdAmountQuantityReturnValue: GetSellQuoteEntity!
    public var getSellQuoteAccountIdAmountQuantityClosure: ((String, String?, String?) async throws -> GetSellQuoteEntity)?

    public func getSellQuote(accountId: String, amount: String?, quantity: String?) async throws -> GetSellQuoteEntity {
        if let error = getSellQuoteAccountIdAmountQuantityThrowableError {
            throw error
        }
        getSellQuoteAccountIdAmountQuantityCallsCount += 1
        getSellQuoteAccountIdAmountQuantityReceivedArguments = (accountId: accountId, amount: amount, quantity: quantity)
        getSellQuoteAccountIdAmountQuantityReceivedInvocations.append((accountId: accountId, amount: amount, quantity: quantity))
        if let getSellQuoteAccountIdAmountQuantityClosure = getSellQuoteAccountIdAmountQuantityClosure {
            return try await getSellQuoteAccountIdAmountQuantityClosure(accountId, amount, quantity)
        } else {
            return getSellQuoteAccountIdAmountQuantityReturnValue
        }
    }

    //MARK: - buyCrypto

    public var buyCryptoAccountIdQuoteIdThrowableError: Error?
    public var buyCryptoAccountIdQuoteIdCallsCount = 0
    public var buyCryptoAccountIdQuoteIdCalled: Bool {
        return buyCryptoAccountIdQuoteIdCallsCount > 0
    }
    public var buyCryptoAccountIdQuoteIdReceivedArguments: (accountId: String, quoteId: String)?
    public var buyCryptoAccountIdQuoteIdReceivedInvocations: [(accountId: String, quoteId: String)] = []
    public var buyCryptoAccountIdQuoteIdReturnValue: BuyCryptoEntity!
    public var buyCryptoAccountIdQuoteIdClosure: ((String, String) async throws -> BuyCryptoEntity)?

    public func buyCrypto(accountId: String, quoteId: String) async throws -> BuyCryptoEntity {
        if let error = buyCryptoAccountIdQuoteIdThrowableError {
            throw error
        }
        buyCryptoAccountIdQuoteIdCallsCount += 1
        buyCryptoAccountIdQuoteIdReceivedArguments = (accountId: accountId, quoteId: quoteId)
        buyCryptoAccountIdQuoteIdReceivedInvocations.append((accountId: accountId, quoteId: quoteId))
        if let buyCryptoAccountIdQuoteIdClosure = buyCryptoAccountIdQuoteIdClosure {
            return try await buyCryptoAccountIdQuoteIdClosure(accountId, quoteId)
        } else {
            return buyCryptoAccountIdQuoteIdReturnValue
        }
    }

    //MARK: - getBuyQuote

    public var getBuyQuoteAccountIdAmountQuantityThrowableError: Error?
    public var getBuyQuoteAccountIdAmountQuantityCallsCount = 0
    public var getBuyQuoteAccountIdAmountQuantityCalled: Bool {
        return getBuyQuoteAccountIdAmountQuantityCallsCount > 0
    }
    public var getBuyQuoteAccountIdAmountQuantityReceivedArguments: (accountId: String, amount: String?, quantity: String?)?
    public var getBuyQuoteAccountIdAmountQuantityReceivedInvocations: [(accountId: String, amount: String?, quantity: String?)] = []
    public var getBuyQuoteAccountIdAmountQuantityReturnValue: GetBuyQuoteEntity!
    public var getBuyQuoteAccountIdAmountQuantityClosure: ((String, String?, String?) async throws -> GetBuyQuoteEntity)?

    public func getBuyQuote(accountId: String, amount: String?, quantity: String?) async throws -> GetBuyQuoteEntity {
        if let error = getBuyQuoteAccountIdAmountQuantityThrowableError {
            throw error
        }
        getBuyQuoteAccountIdAmountQuantityCallsCount += 1
        getBuyQuoteAccountIdAmountQuantityReceivedArguments = (accountId: accountId, amount: amount, quantity: quantity)
        getBuyQuoteAccountIdAmountQuantityReceivedInvocations.append((accountId: accountId, amount: amount, quantity: quantity))
        if let getBuyQuoteAccountIdAmountQuantityClosure = getBuyQuoteAccountIdAmountQuantityClosure {
            return try await getBuyQuoteAccountIdAmountQuantityClosure(accountId, amount, quantity)
        } else {
            return getBuyQuoteAccountIdAmountQuantityReturnValue
        }
    }

}
