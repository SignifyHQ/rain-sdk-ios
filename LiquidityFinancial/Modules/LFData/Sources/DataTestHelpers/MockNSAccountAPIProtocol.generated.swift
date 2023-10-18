// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetSpendData
import BankDomain

public class MockNSAccountAPIProtocol: NSAccountAPIProtocol {

    public init() {}


    //MARK: - getStatements

    public var getStatementsSessionIdFromMonthFromYearToMonthToYearThrowableError: Error?
    public var getStatementsSessionIdFromMonthFromYearToMonthToYearCallsCount = 0
    public var getStatementsSessionIdFromMonthFromYearToMonthToYearCalled: Bool {
        return getStatementsSessionIdFromMonthFromYearToMonthToYearCallsCount > 0
    }
    public var getStatementsSessionIdFromMonthFromYearToMonthToYearReceivedArguments: (sessionId: String, fromMonth: String, fromYear: String, toMonth: String, toYear: String)?
    public var getStatementsSessionIdFromMonthFromYearToMonthToYearReceivedInvocations: [(sessionId: String, fromMonth: String, fromYear: String, toMonth: String, toYear: String)] = []
    public var getStatementsSessionIdFromMonthFromYearToMonthToYearReturnValue: [StatementModel]!
    public var getStatementsSessionIdFromMonthFromYearToMonthToYearClosure: ((String, String, String, String, String) async throws -> [StatementModel])?

    public func getStatements(sessionId: String, fromMonth: String, fromYear: String, toMonth: String, toYear: String) async throws -> [StatementModel] {
        if let error = getStatementsSessionIdFromMonthFromYearToMonthToYearThrowableError {
            throw error
        }
        getStatementsSessionIdFromMonthFromYearToMonthToYearCallsCount += 1
        getStatementsSessionIdFromMonthFromYearToMonthToYearReceivedArguments = (sessionId: sessionId, fromMonth: fromMonth, fromYear: fromYear, toMonth: toMonth, toYear: toYear)
        getStatementsSessionIdFromMonthFromYearToMonthToYearReceivedInvocations.append((sessionId: sessionId, fromMonth: fromMonth, fromYear: fromYear, toMonth: toMonth, toYear: toYear))
        if let getStatementsSessionIdFromMonthFromYearToMonthToYearClosure = getStatementsSessionIdFromMonthFromYearToMonthToYearClosure {
            return try await getStatementsSessionIdFromMonthFromYearToMonthToYearClosure(sessionId, fromMonth, fromYear, toMonth, toYear)
        } else {
            return getStatementsSessionIdFromMonthFromYearToMonthToYearReturnValue
        }
    }

}
