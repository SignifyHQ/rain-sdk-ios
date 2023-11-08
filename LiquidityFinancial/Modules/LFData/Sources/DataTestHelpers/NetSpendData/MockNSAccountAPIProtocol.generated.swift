// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetSpendData
import NetspendDomain

public class MockNSAccountAPIProtocol: NSAccountAPIProtocol {

    public init() {}


    //MARK: - getStatements

    public var getStatementsSessionIdParametersThrowableError: Error?
    public var getStatementsSessionIdParametersCallsCount = 0
    public var getStatementsSessionIdParametersCalled: Bool {
        return getStatementsSessionIdParametersCallsCount > 0
    }
    public var getStatementsSessionIdParametersReceivedArguments: (sessionId: String, parameters: GetStatementParameters)?
    public var getStatementsSessionIdParametersReceivedInvocations: [(sessionId: String, parameters: GetStatementParameters)] = []
    public var getStatementsSessionIdParametersReturnValue: [StatementModel]!
    public var getStatementsSessionIdParametersClosure: ((String, GetStatementParameters) async throws -> [StatementModel])?

    public func getStatements(sessionId: String, parameters: GetStatementParameters) async throws -> [StatementModel] {
        if let error = getStatementsSessionIdParametersThrowableError {
            throw error
        }
        getStatementsSessionIdParametersCallsCount += 1
        getStatementsSessionIdParametersReceivedArguments = (sessionId: sessionId, parameters: parameters)
        getStatementsSessionIdParametersReceivedInvocations.append((sessionId: sessionId, parameters: parameters))
        if let getStatementsSessionIdParametersClosure = getStatementsSessionIdParametersClosure {
            return try await getStatementsSessionIdParametersClosure(sessionId, parameters)
        } else {
            return getStatementsSessionIdParametersReturnValue
        }
    }

    //MARK: - getAccounts

    public var getAccountsThrowableError: Error?
    public var getAccountsCallsCount = 0
    public var getAccountsCalled: Bool {
        return getAccountsCallsCount > 0
    }
    public var getAccountsReturnValue: [APINetspendAccount]!
    public var getAccountsClosure: (() async throws -> [APINetspendAccount])?

    public func getAccounts() async throws -> [APINetspendAccount] {
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
    public var getAccountDetailIdReturnValue: APINetspendAccount!
    public var getAccountDetailIdClosure: ((String) async throws -> APINetspendAccount)?

    public func getAccountDetail(id: String) async throws -> APINetspendAccount {
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
    public var getAccountLimitsReturnValue: APINetspendAccountLimits!
    public var getAccountLimitsClosure: (() async throws -> APINetspendAccountLimits)?

    public func getAccountLimits() async throws -> APINetspendAccountLimits {
        if let error = getAccountLimitsThrowableError {
            throw error
        }
        getAccountLimitsCallsCount += 1
        if let getAccountLimitsClosure = getAccountLimitsClosure {
            return try await getAccountLimitsClosure()
        } else {
            return getAccountLimitsReturnValue
        }
    }

}
