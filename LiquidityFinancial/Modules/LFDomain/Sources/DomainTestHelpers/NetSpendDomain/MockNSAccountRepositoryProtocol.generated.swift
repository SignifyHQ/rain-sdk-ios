// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockNSAccountRepositoryProtocol: NSAccountRepositoryProtocol {

    public init() {}


    //MARK: - getStatements

    public var getStatementsSessionIdParameterThrowableError: Error?
    public var getStatementsSessionIdParameterCallsCount = 0
    public var getStatementsSessionIdParameterCalled: Bool {
        return getStatementsSessionIdParameterCallsCount > 0
    }
    public var getStatementsSessionIdParameterReceivedArguments: (sessionId: String, parameter: GetStatementParameterEntity)?
    public var getStatementsSessionIdParameterReceivedInvocations: [(sessionId: String, parameter: GetStatementParameterEntity)] = []
    public var getStatementsSessionIdParameterReturnValue: [StatementModel]!
    public var getStatementsSessionIdParameterClosure: ((String, GetStatementParameterEntity) async throws -> [StatementModel])?

    public func getStatements(sessionId: String, parameter: GetStatementParameterEntity) async throws -> [StatementModel] {
        if let error = getStatementsSessionIdParameterThrowableError {
            throw error
        }
        getStatementsSessionIdParameterCallsCount += 1
        getStatementsSessionIdParameterReceivedArguments = (sessionId: sessionId, parameter: parameter)
        getStatementsSessionIdParameterReceivedInvocations.append((sessionId: sessionId, parameter: parameter))
        if let getStatementsSessionIdParameterClosure = getStatementsSessionIdParameterClosure {
            return try await getStatementsSessionIdParameterClosure(sessionId, parameter)
        } else {
            return getStatementsSessionIdParameterReturnValue
        }
    }

    //MARK: - getAccounts

    public var getAccountsThrowableError: Error?
    public var getAccountsCallsCount = 0
    public var getAccountsCalled: Bool {
        return getAccountsCallsCount > 0
    }
    public var getAccountsReturnValue: [NSAccountEntity]!
    public var getAccountsClosure: (() async throws -> [NSAccountEntity])?

    public func getAccounts() async throws -> [NSAccountEntity] {
        if let error = getAccountsThrowableError {
            throw error
        }
        getAccountsCallsCount += 1
        if let getAccountsClosure = getAccountsClosure {
            return try await getAccountsClosure()
        } else {
            return getAccountsReturnValue
        }
    }

    //MARK: - getAccountDetail

    public var getAccountDetailIdThrowableError: Error?
    public var getAccountDetailIdCallsCount = 0
    public var getAccountDetailIdCalled: Bool {
        return getAccountDetailIdCallsCount > 0
    }
    public var getAccountDetailIdReceivedId: String?
    public var getAccountDetailIdReceivedInvocations: [String] = []
    public var getAccountDetailIdReturnValue: NSAccountEntity!
    public var getAccountDetailIdClosure: ((String) async throws -> NSAccountEntity)?

    public func getAccountDetail(id: String) async throws -> NSAccountEntity {
        if let error = getAccountDetailIdThrowableError {
            throw error
        }
        getAccountDetailIdCallsCount += 1
        getAccountDetailIdReceivedId = id
        getAccountDetailIdReceivedInvocations.append(id)
        if let getAccountDetailIdClosure = getAccountDetailIdClosure {
            return try await getAccountDetailIdClosure(id)
        } else {
            return getAccountDetailIdReturnValue
        }
    }

    //MARK: - getAccountLimits

    public var getAccountLimitsThrowableError: Error?
    public var getAccountLimitsCallsCount = 0
    public var getAccountLimitsCalled: Bool {
        return getAccountLimitsCallsCount > 0
    }
    public var getAccountLimitsReturnValue: (any NSAccountLimitsEntity)?
    public var getAccountLimitsClosure: (() async throws -> any NSAccountLimitsEntity)?

    public func getAccountLimits() async throws -> any NSAccountLimitsEntity {
        if let error = getAccountLimitsThrowableError {
            throw error
        }
        getAccountLimitsCallsCount += 1
        if let getAccountLimitsClosure = getAccountLimitsClosure {
            return try await getAccountLimitsClosure()
        } else {
          return getAccountLimitsReturnValue!
        }
    }

}
