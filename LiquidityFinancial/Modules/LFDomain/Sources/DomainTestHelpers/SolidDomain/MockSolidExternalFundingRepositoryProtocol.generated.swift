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

}
