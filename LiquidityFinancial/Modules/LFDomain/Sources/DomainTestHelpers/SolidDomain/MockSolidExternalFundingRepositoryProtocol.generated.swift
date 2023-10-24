// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidExternalFundingRepositoryProtocol: SolidExternalFundingRepositoryProtocol {

    public init() {}


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

}
