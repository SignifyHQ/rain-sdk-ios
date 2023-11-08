// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidAccountRepositoryProtocol: SolidAccountRepositoryProtocol {

    public init() {}


    //MARK: - getAccounts

    public var getAccountsThrowableError: Error?
    public var getAccountsCallsCount = 0
    public var getAccountsCalled: Bool {
        return getAccountsCallsCount > 0
    }
    public var getAccountsReturnValue: [SolidAccountEntity]!
    public var getAccountsClosure: (() async throws -> [SolidAccountEntity])?

    public func getAccounts() async throws -> [SolidAccountEntity] {
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
    public var getAccountDetailIdReturnValue: SolidAccountEntity!
    public var getAccountDetailIdClosure: ((String) async throws -> SolidAccountEntity)?

    public func getAccountDetail(id: String) async throws -> SolidAccountEntity {
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
    public var getAccountLimitsReturnValue: [SolidAccountLimitsEntity]!
    public var getAccountLimitsClosure: (() async throws -> [SolidAccountLimitsEntity])?

    public func getAccountLimits() async throws -> [SolidAccountLimitsEntity] {
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
