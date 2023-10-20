// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation

public class MockSolidAPIProtocol: SolidAPIProtocol {

    public init() {}


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
    public var plaidLinkAccountIdTokenPlaidAccountIdReturnValue: SolidContact!
    public var plaidLinkAccountIdTokenPlaidAccountIdClosure: ((String, String, String) async throws -> SolidContact)?

    public func plaidLink(accountId: String, token: String, plaidAccountId: String) async throws -> SolidContact {
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

}
