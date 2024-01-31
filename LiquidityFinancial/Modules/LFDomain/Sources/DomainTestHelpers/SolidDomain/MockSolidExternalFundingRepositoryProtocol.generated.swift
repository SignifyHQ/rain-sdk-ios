// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidExternalFundingRepositoryProtocol: SolidExternalFundingRepositoryProtocol {

    public init() {}


    //MARK: - getLinkedSources

    public var getLinkedSourcesAccountIDThrowableError: Error?
    public var getLinkedSourcesAccountIDCallsCount = 0
    public var getLinkedSourcesAccountIDCalled: Bool {
        return getLinkedSourcesAccountIDCallsCount > 0
    }
    public var getLinkedSourcesAccountIDReceivedAccountID: String?
    public var getLinkedSourcesAccountIDReceivedInvocations: [String] = []
    public var getLinkedSourcesAccountIDReturnValue: [SolidContactEntity]!
    public var getLinkedSourcesAccountIDClosure: ((String) async throws -> [SolidContactEntity])?

    public func getLinkedSources(accountID: String) async throws -> [SolidContactEntity] {
        if let error = getLinkedSourcesAccountIDThrowableError {
            throw error
        }
        getLinkedSourcesAccountIDCallsCount += 1
        getLinkedSourcesAccountIDReceivedAccountID = accountID
        getLinkedSourcesAccountIDReceivedInvocations.append(accountID)
        if let getLinkedSourcesAccountIDClosure = getLinkedSourcesAccountIDClosure {
            return try await getLinkedSourcesAccountIDClosure(accountID)
        } else {
            return getLinkedSourcesAccountIDReturnValue
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
    public var createDebitCardTokenAccountIDReturnValue: SolidDebitCardTokenEntity!
    public var createDebitCardTokenAccountIDClosure: ((String) async throws -> SolidDebitCardTokenEntity)?

    public func createDebitCardToken(accountID: String) async throws -> SolidDebitCardTokenEntity {
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

    public var createPlaidTokenAccountIDThrowableError: Error?
    public var createPlaidTokenAccountIDCallsCount = 0
    public var createPlaidTokenAccountIDCalled: Bool {
        return createPlaidTokenAccountIDCallsCount > 0
    }
    public var createPlaidTokenAccountIDReceivedAccountID: String?
    public var createPlaidTokenAccountIDReceivedInvocations: [String] = []
    public var createPlaidTokenAccountIDReturnValue: CreatePlaidTokenResponseEntity!
    public var createPlaidTokenAccountIDClosure: ((String) async throws -> CreatePlaidTokenResponseEntity)?

    public func createPlaidToken(accountID: String) async throws -> CreatePlaidTokenResponseEntity {
        if let error = createPlaidTokenAccountIDThrowableError {
            throw error
        }
        createPlaidTokenAccountIDCallsCount += 1
        createPlaidTokenAccountIDReceivedAccountID = accountID
        createPlaidTokenAccountIDReceivedInvocations.append(accountID)
        if let createPlaidTokenAccountIDClosure = createPlaidTokenAccountIDClosure {
            return try await createPlaidTokenAccountIDClosure(accountID)
        } else {
            return createPlaidTokenAccountIDReturnValue
        }
    }

    //MARK: - linkPlaid

    public var linkPlaidAccountIdTokenPlaidAccountIdThrowableError: Error?
    public var linkPlaidAccountIdTokenPlaidAccountIdCallsCount = 0
    public var linkPlaidAccountIdTokenPlaidAccountIdCalled: Bool {
        return linkPlaidAccountIdTokenPlaidAccountIdCallsCount > 0
    }
    public var linkPlaidAccountIdTokenPlaidAccountIdReceivedArguments: (accountId: String, token: String, plaidAccountId: String)?
    public var linkPlaidAccountIdTokenPlaidAccountIdReceivedInvocations: [(accountId: String, token: String, plaidAccountId: String)] = []
    public var linkPlaidAccountIdTokenPlaidAccountIdReturnValue: (any SolidContactEntity)!
    public var linkPlaidAccountIdTokenPlaidAccountIdClosure: ((String, String, String) async throws -> any SolidContactEntity)?

    public func linkPlaid(accountId: String, token: String, plaidAccountId: String) async throws -> any SolidContactEntity {
        if let error = linkPlaidAccountIdTokenPlaidAccountIdThrowableError {
            throw error
        }
        linkPlaidAccountIdTokenPlaidAccountIdCallsCount += 1
        linkPlaidAccountIdTokenPlaidAccountIdReceivedArguments = (accountId: accountId, token: token, plaidAccountId: plaidAccountId)
        linkPlaidAccountIdTokenPlaidAccountIdReceivedInvocations.append((accountId: accountId, token: token, plaidAccountId: plaidAccountId))
        if let linkPlaidAccountIdTokenPlaidAccountIdClosure = linkPlaidAccountIdTokenPlaidAccountIdClosure {
            return try await linkPlaidAccountIdTokenPlaidAccountIdClosure(accountId, token, plaidAccountId)
        } else {
            return linkPlaidAccountIdTokenPlaidAccountIdReturnValue
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
    public var unlinkContactIdReturnValue: SolidUnlinkContactResponseEntity!
    public var unlinkContactIdClosure: ((String) async throws -> SolidUnlinkContactResponseEntity)?

    public func unlinkContact(id: String) async throws -> SolidUnlinkContactResponseEntity {
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
    public var getWireTransferAccountIdReturnValue: SolidWireTransferResponseEntity!
    public var getWireTransferAccountIdClosure: ((String) async throws -> SolidWireTransferResponseEntity)?

    public func getWireTransfer(accountId: String) async throws -> SolidWireTransferResponseEntity {
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
    public var newTransactionTypeAccountIdContactIdAmountReturnValue: SolidExternalTransactionResponseEntity!
    public var newTransactionTypeAccountIdContactIdAmountClosure: ((SolidExternalTransactionType, String, String, Double) async throws -> SolidExternalTransactionResponseEntity)?

    public func newTransaction(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double) async throws -> SolidExternalTransactionResponseEntity {
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
    public var estimateDebitCardFeeAccountIdContactIdAmountReturnValue: SolidDebitCardTransferFeeResponseEntity!
    public var estimateDebitCardFeeAccountIdContactIdAmountClosure: ((String, String, Double) async throws -> SolidDebitCardTransferFeeResponseEntity)?

    public func estimateDebitCardFee(accountId: String, contactId: String, amount: Double) async throws -> SolidDebitCardTransferFeeResponseEntity {
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

    //MARK: - createPinwheelToken

    public var createPinwheelTokenAccountIdThrowableError: Error?
    public var createPinwheelTokenAccountIdCallsCount = 0
    public var createPinwheelTokenAccountIdCalled: Bool {
        return createPinwheelTokenAccountIdCallsCount > 0
    }
    public var createPinwheelTokenAccountIdReceivedAccountId: String?
    public var createPinwheelTokenAccountIdReceivedInvocations: [String] = []
    public var createPinwheelTokenAccountIdReturnValue: SolidExternalPinwheelTokenResponseEntity!
    public var createPinwheelTokenAccountIdClosure: ((String) async throws -> SolidExternalPinwheelTokenResponseEntity)?

    public func createPinwheelToken(accountId: String) async throws -> SolidExternalPinwheelTokenResponseEntity {
        if let error = createPinwheelTokenAccountIdThrowableError {
            throw error
        }
        createPinwheelTokenAccountIdCallsCount += 1
        createPinwheelTokenAccountIdReceivedAccountId = accountId
        createPinwheelTokenAccountIdReceivedInvocations.append(accountId)
        if let createPinwheelTokenAccountIdClosure = createPinwheelTokenAccountIdClosure {
            return try await createPinwheelTokenAccountIdClosure(accountId)
        } else {
            return createPinwheelTokenAccountIdReturnValue
        }
    }

    //MARK: - cancelACHTransaction

    public var cancelACHTransactionLiquidityTransactionIDThrowableError: Error?
    public var cancelACHTransactionLiquidityTransactionIDCallsCount = 0
    public var cancelACHTransactionLiquidityTransactionIDCalled: Bool {
        return cancelACHTransactionLiquidityTransactionIDCallsCount > 0
    }
    public var cancelACHTransactionLiquidityTransactionIDReceivedLiquidityTransactionID: String?
    public var cancelACHTransactionLiquidityTransactionIDReceivedInvocations: [String] = []
    public var cancelACHTransactionLiquidityTransactionIDReturnValue: SolidExternalTransactionResponseEntity!
    public var cancelACHTransactionLiquidityTransactionIDClosure: ((String) async throws -> SolidExternalTransactionResponseEntity)?

    public func cancelACHTransaction(liquidityTransactionID: String) async throws -> SolidExternalTransactionResponseEntity {
        if let error = cancelACHTransactionLiquidityTransactionIDThrowableError {
            throw error
        }
        cancelACHTransactionLiquidityTransactionIDCallsCount += 1
        cancelACHTransactionLiquidityTransactionIDReceivedLiquidityTransactionID = liquidityTransactionID
        cancelACHTransactionLiquidityTransactionIDReceivedInvocations.append(liquidityTransactionID)
        if let cancelACHTransactionLiquidityTransactionIDClosure = cancelACHTransactionLiquidityTransactionIDClosure {
            return try await cancelACHTransactionLiquidityTransactionIDClosure(liquidityTransactionID)
        } else {
            return cancelACHTransactionLiquidityTransactionIDReturnValue
        }
    }

}
