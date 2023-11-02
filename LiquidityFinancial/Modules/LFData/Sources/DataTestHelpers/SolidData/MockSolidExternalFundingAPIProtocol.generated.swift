// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidData
import SolidDomain

public class MockSolidExternalFundingAPIProtocol: SolidExternalFundingAPIProtocol {

    public init() {}


    //MARK: - getLinkedSources

    public var getLinkedSourcesAccountIdThrowableError: Error?
    public var getLinkedSourcesAccountIdCallsCount = 0
    public var getLinkedSourcesAccountIdCalled: Bool {
        return getLinkedSourcesAccountIdCallsCount > 0
    }
    public var getLinkedSourcesAccountIdReceivedAccountId: String?
    public var getLinkedSourcesAccountIdReceivedInvocations: [String] = []
    public var getLinkedSourcesAccountIdReturnValue: [APISolidContact]!
    public var getLinkedSourcesAccountIdClosure: ((String) async throws -> [APISolidContact])?

    public func getLinkedSources(accountId: String) async throws -> [APISolidContact] {
        if let error = getLinkedSourcesAccountIdThrowableError {
            throw error
        }
        getLinkedSourcesAccountIdCallsCount += 1
        getLinkedSourcesAccountIdReceivedAccountId = accountId
        getLinkedSourcesAccountIdReceivedInvocations.append(accountId)
        if let getLinkedSourcesAccountIdClosure = getLinkedSourcesAccountIdClosure {
            return try await getLinkedSourcesAccountIdClosure(accountId)
        } else {
            return getLinkedSourcesAccountIdReturnValue
        }
    }

    //MARK: - createDebitCardToken

    public var createDebitCardTokenAccountIDThrowableError: Error?
    public var createDebitCardTokenAccountIDCallsCount = 0
    public var createDebitCardTokenAccountIDCalled: Bool {
        return createDebitCardTokenAccountIDCallsCount > 0
    }
    public var createDebitCardTokenAccountIDReceivedAccountID: String?
    public var createDebitCardTokenAccountIDReceivedInvocations: [String] = []
    public var createDebitCardTokenAccountIDReturnValue: APISolidDebitCardToken!
    public var createDebitCardTokenAccountIDClosure: ((String) async throws -> APISolidDebitCardToken)?

    public func createDebitCardToken(accountID: String) async throws -> APISolidDebitCardToken {
        if let error = createDebitCardTokenAccountIDThrowableError {
            throw error
        }
        createDebitCardTokenAccountIDCallsCount += 1
        createDebitCardTokenAccountIDReceivedAccountID = accountID
        createDebitCardTokenAccountIDReceivedInvocations.append(accountID)
        if let createDebitCardTokenAccountIDClosure = createDebitCardTokenAccountIDClosure {
            return try await createDebitCardTokenAccountIDClosure(accountID)
        } else {
            return createDebitCardTokenAccountIDReturnValue
        }
    }

    //MARK: - createPlaidToken

    public var createPlaidTokenAccountIdThrowableError: Error?
    public var createPlaidTokenAccountIdCallsCount = 0
    public var createPlaidTokenAccountIdCalled: Bool {
        return createPlaidTokenAccountIdCallsCount > 0
    }
    public var createPlaidTokenAccountIdReceivedAccountId: String?
    public var createPlaidTokenAccountIdReceivedInvocations: [String] = []
    public var createPlaidTokenAccountIdReturnValue: APICreatePlaidTokenResponse!
    public var createPlaidTokenAccountIdClosure: ((String) async throws -> APICreatePlaidTokenResponse)?

    public func createPlaidToken(accountId: String) async throws -> APICreatePlaidTokenResponse {
        if let error = createPlaidTokenAccountIdThrowableError {
            throw error
        }
        createPlaidTokenAccountIdCallsCount += 1
        createPlaidTokenAccountIdReceivedAccountId = accountId
        createPlaidTokenAccountIdReceivedInvocations.append(accountId)
        if let createPlaidTokenAccountIdClosure = createPlaidTokenAccountIdClosure {
            return try await createPlaidTokenAccountIdClosure(accountId)
        } else {
            return createPlaidTokenAccountIdReturnValue
        }
    }

    //MARK: - plaidLink

    public var plaidLinkAccountIdTokenPlaidAccountIdThrowableError: Error?
    public var plaidLinkAccountIdTokenPlaidAccountIdCallsCount = 0
    public var plaidLinkAccountIdTokenPlaidAccountIdCalled: Bool {
        return plaidLinkAccountIdTokenPlaidAccountIdCallsCount > 0
    }
    public var plaidLinkAccountIdTokenPlaidAccountIdReceivedArguments: (accountId: String, token: String, plaidAccountId: String)?
    public var plaidLinkAccountIdTokenPlaidAccountIdReceivedInvocations: [(accountId: String, token: String, plaidAccountId: String)] = []
    public var plaidLinkAccountIdTokenPlaidAccountIdReturnValue: APISolidContact!
    public var plaidLinkAccountIdTokenPlaidAccountIdClosure: ((String, String, String) async throws -> APISolidContact)?

    public func plaidLink(accountId: String, token: String, plaidAccountId: String) async throws -> APISolidContact {
        if let error = plaidLinkAccountIdTokenPlaidAccountIdThrowableError {
            throw error
        }
        plaidLinkAccountIdTokenPlaidAccountIdCallsCount += 1
        plaidLinkAccountIdTokenPlaidAccountIdReceivedArguments = (accountId: accountId, token: token, plaidAccountId: plaidAccountId)
        plaidLinkAccountIdTokenPlaidAccountIdReceivedInvocations.append((accountId: accountId, token: token, plaidAccountId: plaidAccountId))
        if let plaidLinkAccountIdTokenPlaidAccountIdClosure = plaidLinkAccountIdTokenPlaidAccountIdClosure {
            return try await plaidLinkAccountIdTokenPlaidAccountIdClosure(accountId, token, plaidAccountId)
        } else {
            return plaidLinkAccountIdTokenPlaidAccountIdReturnValue
        }
    }

    //MARK: - unlinkContact

    public var unlinkContactIdThrowableError: Error?
    public var unlinkContactIdCallsCount = 0
    public var unlinkContactIdCalled: Bool {
        return unlinkContactIdCallsCount > 0
    }
    public var unlinkContactIdReceivedId: String?
    public var unlinkContactIdReceivedInvocations: [String] = []
    public var unlinkContactIdReturnValue: APISolidUnlinkContactResponse!
    public var unlinkContactIdClosure: ((String) async throws -> APISolidUnlinkContactResponse)?

    public func unlinkContact(id: String) async throws -> APISolidUnlinkContactResponse {
        if let error = unlinkContactIdThrowableError {
            throw error
        }
        unlinkContactIdCallsCount += 1
        unlinkContactIdReceivedId = id
        unlinkContactIdReceivedInvocations.append(id)
        if let unlinkContactIdClosure = unlinkContactIdClosure {
            return try await unlinkContactIdClosure(id)
        } else {
            return unlinkContactIdReturnValue
        }
    }

    //MARK: - getWireTransfer

    public var getWireTransferAccountIdThrowableError: Error?
    public var getWireTransferAccountIdCallsCount = 0
    public var getWireTransferAccountIdCalled: Bool {
        return getWireTransferAccountIdCallsCount > 0
    }
    public var getWireTransferAccountIdReceivedAccountId: String?
    public var getWireTransferAccountIdReceivedInvocations: [String] = []
    public var getWireTransferAccountIdReturnValue: APISolidWireTransferResponse!
    public var getWireTransferAccountIdClosure: ((String) async throws -> APISolidWireTransferResponse)?

    public func getWireTransfer(accountId: String) async throws -> APISolidWireTransferResponse {
        if let error = getWireTransferAccountIdThrowableError {
            throw error
        }
        getWireTransferAccountIdCallsCount += 1
        getWireTransferAccountIdReceivedAccountId = accountId
        getWireTransferAccountIdReceivedInvocations.append(accountId)
        if let getWireTransferAccountIdClosure = getWireTransferAccountIdClosure {
            return try await getWireTransferAccountIdClosure(accountId)
        } else {
            return getWireTransferAccountIdReturnValue
        }
    }

    //MARK: - newTransaction

    public var newTransactionTypeAccountIdContactIdAmountThrowableError: Error?
    public var newTransactionTypeAccountIdContactIdAmountCallsCount = 0
    public var newTransactionTypeAccountIdContactIdAmountCalled: Bool {
        return newTransactionTypeAccountIdContactIdAmountCallsCount > 0
    }
    public var newTransactionTypeAccountIdContactIdAmountReceivedArguments: (type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double)?
    public var newTransactionTypeAccountIdContactIdAmountReceivedInvocations: [(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double)] = []
    public var newTransactionTypeAccountIdContactIdAmountReturnValue: APISolidExternalTransactionResponse!
    public var newTransactionTypeAccountIdContactIdAmountClosure: ((SolidExternalTransactionType, String, String, Double) async throws -> APISolidExternalTransactionResponse)?

    public func newTransaction(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double) async throws -> APISolidExternalTransactionResponse {
        if let error = newTransactionTypeAccountIdContactIdAmountThrowableError {
            throw error
        }
        newTransactionTypeAccountIdContactIdAmountCallsCount += 1
        newTransactionTypeAccountIdContactIdAmountReceivedArguments = (type: type, accountId: accountId, contactId: contactId, amount: amount)
        newTransactionTypeAccountIdContactIdAmountReceivedInvocations.append((type: type, accountId: accountId, contactId: contactId, amount: amount))
        if let newTransactionTypeAccountIdContactIdAmountClosure = newTransactionTypeAccountIdContactIdAmountClosure {
            return try await newTransactionTypeAccountIdContactIdAmountClosure(type, accountId, contactId, amount)
        } else {
            return newTransactionTypeAccountIdContactIdAmountReturnValue
        }
    }

    //MARK: - estimateDebitCardFee

    public var estimateDebitCardFeeAccountIdContactIdAmountThrowableError: Error?
    public var estimateDebitCardFeeAccountIdContactIdAmountCallsCount = 0
    public var estimateDebitCardFeeAccountIdContactIdAmountCalled: Bool {
        return estimateDebitCardFeeAccountIdContactIdAmountCallsCount > 0
    }
    public var estimateDebitCardFeeAccountIdContactIdAmountReceivedArguments: (accountId: String, contactId: String, amount: Double)?
    public var estimateDebitCardFeeAccountIdContactIdAmountReceivedInvocations: [(accountId: String, contactId: String, amount: Double)] = []
    public var estimateDebitCardFeeAccountIdContactIdAmountReturnValue: APISolidDebitCardTransferFeeResponse!
    public var estimateDebitCardFeeAccountIdContactIdAmountClosure: ((String, String, Double) async throws -> APISolidDebitCardTransferFeeResponse)?

    public func estimateDebitCardFee(accountId: String, contactId: String, amount: Double) async throws -> APISolidDebitCardTransferFeeResponse {
        if let error = estimateDebitCardFeeAccountIdContactIdAmountThrowableError {
            throw error
        }
        estimateDebitCardFeeAccountIdContactIdAmountCallsCount += 1
        estimateDebitCardFeeAccountIdContactIdAmountReceivedArguments = (accountId: accountId, contactId: contactId, amount: amount)
        estimateDebitCardFeeAccountIdContactIdAmountReceivedInvocations.append((accountId: accountId, contactId: contactId, amount: amount))
        if let estimateDebitCardFeeAccountIdContactIdAmountClosure = estimateDebitCardFeeAccountIdContactIdAmountClosure {
            return try await estimateDebitCardFeeAccountIdContactIdAmountClosure(accountId, contactId, amount)
        } else {
            return estimateDebitCardFeeAccountIdContactIdAmountReturnValue
        }
    }

}
