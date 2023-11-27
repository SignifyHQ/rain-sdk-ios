// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidData

public class MockSolidAccountAPIProtocol: SolidAccountAPIProtocol {

    public init() {}


    //MARK: - getAccounts

    public var getAccountsThrowableError: Error?
    public var getAccountsCallsCount = 0
    public var getAccountsCalled: Bool {
        return getAccountsCallsCount > 0
    }
    public var getAccountsReturnValue: [APISolidAccount]!
    public var getAccountsClosure: (() async throws -> [APISolidAccount])?

    public func getAccounts() async throws -> [APISolidAccount] {
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
    public var getAccountDetailIdReturnValue: APISolidAccount!
    public var getAccountDetailIdClosure: ((String) async throws -> APISolidAccount)?

    public func getAccountDetail(id: String) async throws -> APISolidAccount {
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
    public var getAccountLimitsReturnValue: [APISolidAccountLimits]!
    public var getAccountLimitsClosure: (() async throws -> [APISolidAccountLimits])?

    public func getAccountLimits() async throws -> [APISolidAccountLimits] {
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

    //MARK: - getAllStatement

    public var getAllStatementLiquidityAccountIdThrowableError: Error?
    public var getAllStatementLiquidityAccountIdCallsCount = 0
    public var getAllStatementLiquidityAccountIdCalled: Bool {
        return getAllStatementLiquidityAccountIdCallsCount > 0
    }
    public var getAllStatementLiquidityAccountIdReceivedLiquidityAccountId: String?
    public var getAllStatementLiquidityAccountIdReceivedInvocations: [String] = []
    public var getAllStatementLiquidityAccountIdReturnValue: [APISolidAccountStatementList]!
    public var getAllStatementLiquidityAccountIdClosure: ((String) async throws -> [APISolidAccountStatementList])?

    public func getAllStatement(liquidityAccountId: String) async throws -> [APISolidAccountStatementList] {
        if let error = getAllStatementLiquidityAccountIdThrowableError {
            throw error
        }
        getAllStatementLiquidityAccountIdCallsCount += 1
        getAllStatementLiquidityAccountIdReceivedLiquidityAccountId = liquidityAccountId
        getAllStatementLiquidityAccountIdReceivedInvocations.append(liquidityAccountId)
        if let getAllStatementLiquidityAccountIdClosure = getAllStatementLiquidityAccountIdClosure {
            return try await getAllStatementLiquidityAccountIdClosure(liquidityAccountId)
        } else {
            return getAllStatementLiquidityAccountIdReturnValue
        }
    }

    //MARK: - getStatement

    public var getStatementLiquidityAccountIdFileNameYearMonthThrowableError: Error?
    public var getStatementLiquidityAccountIdFileNameYearMonthCallsCount = 0
    public var getStatementLiquidityAccountIdFileNameYearMonthCalled: Bool {
        return getStatementLiquidityAccountIdFileNameYearMonthCallsCount > 0
    }
    public var getStatementLiquidityAccountIdFileNameYearMonthReceivedArguments: (liquidityAccountId: String, fileName: String, year: String, month: String)?
    public var getStatementLiquidityAccountIdFileNameYearMonthReceivedInvocations: [(liquidityAccountId: String, fileName: String, year: String, month: String)] = []
    public var getStatementLiquidityAccountIdFileNameYearMonthReturnValue: APISolidAccountStatementItem!
    public var getStatementLiquidityAccountIdFileNameYearMonthClosure: ((String, String, String, String) async throws -> APISolidAccountStatementItem)?

    public func getStatement(liquidityAccountId: String, fileName: String, year: String, month: String) async throws -> APISolidAccountStatementItem {
        if let error = getStatementLiquidityAccountIdFileNameYearMonthThrowableError {
            throw error
        }
        getStatementLiquidityAccountIdFileNameYearMonthCallsCount += 1
        getStatementLiquidityAccountIdFileNameYearMonthReceivedArguments = (liquidityAccountId: liquidityAccountId, fileName: fileName, year: year, month: month)
        getStatementLiquidityAccountIdFileNameYearMonthReceivedInvocations.append((liquidityAccountId: liquidityAccountId, fileName: fileName, year: year, month: month))
        if let getStatementLiquidityAccountIdFileNameYearMonthClosure = getStatementLiquidityAccountIdFileNameYearMonthClosure {
            return try await getStatementLiquidityAccountIdFileNameYearMonthClosure(liquidityAccountId, fileName, year, month)
        } else {
            return getStatementLiquidityAccountIdFileNameYearMonthReturnValue
        }
    }

}
