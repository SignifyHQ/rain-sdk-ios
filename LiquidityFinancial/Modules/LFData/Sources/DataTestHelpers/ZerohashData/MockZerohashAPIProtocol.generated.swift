// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import ZerohashDomain
import ZerohashData
import AccountData

public class MockZerohashAPIProtocol: ZerohashAPIProtocol {

    public init() {}


    //MARK: - sendCrypto

    public var sendCryptoAccountIdDestinationAddressAmountThrowableError: Error?
    public var sendCryptoAccountIdDestinationAddressAmountCallsCount = 0
    public var sendCryptoAccountIdDestinationAddressAmountCalled: Bool {
        return sendCryptoAccountIdDestinationAddressAmountCallsCount > 0
    }
    public var sendCryptoAccountIdDestinationAddressAmountReceivedArguments: (accountId: String, destinationAddress: String, amount: Double)?
    public var sendCryptoAccountIdDestinationAddressAmountReceivedInvocations: [(accountId: String, destinationAddress: String, amount: Double)] = []
    public var sendCryptoAccountIdDestinationAddressAmountReturnValue: APITransaction!
    public var sendCryptoAccountIdDestinationAddressAmountClosure: ((String, String, Double) async throws -> APITransaction)?

    public func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> APITransaction {
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
    public var executeAccountIdQuoteIdReturnValue: APITransaction!
    public var executeAccountIdQuoteIdClosure: ((String, String) async throws -> APITransaction)?

    public func execute(accountId: String, quoteId: String) async throws -> APITransaction {
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
    public var getOnboardingStepReturnValue: APIZHOnboardingStep!
    public var getOnboardingStepClosure: (() async throws -> APIZHOnboardingStep)?

    public func getOnboardingStep() async throws -> APIZHOnboardingStep {
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
    public var getTaxFileAccountIdReturnValue: [APITaxFile]!
    public var getTaxFileAccountIdClosure: ((String) async throws -> [APITaxFile])?

    public func getTaxFile(accountId: String) async throws -> [APITaxFile] {
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
    public var sellCryptoAccountIdQuoteIdReturnValue: APISellCrypto!
    public var sellCryptoAccountIdQuoteIdClosure: ((String, String) async throws -> APISellCrypto)?

    public func sellCrypto(accountId: String, quoteId: String) async throws -> APISellCrypto {
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
    public var getSellQuoteAccountIdAmountQuantityReturnValue: APIGetSellQuote!
    public var getSellQuoteAccountIdAmountQuantityClosure: ((String, String?, String?) async throws -> APIGetSellQuote)?

    public func getSellQuote(accountId: String, amount: String?, quantity: String?) async throws -> APIGetSellQuote {
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

}
