// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import AccountData
import Foundation
import ZerohashData
import ZerohashDomain

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

}
