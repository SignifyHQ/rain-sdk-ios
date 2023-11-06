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

}
