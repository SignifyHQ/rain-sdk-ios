// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import OnboardingDomain

public class MockLoginUseCaseProtocol: LoginUseCaseProtocol {

    public init() {}


    //MARK: - execute

    public var executeIsNewAuthParametersThrowableError: Error?
    public var executeIsNewAuthParametersCallsCount = 0
    public var executeIsNewAuthParametersCalled: Bool {
        return executeIsNewAuthParametersCallsCount > 0
    }
    public var executeIsNewAuthParametersReceivedArguments: (isNewAuth: Bool, parameters: LoginParametersEntity)?
    public var executeIsNewAuthParametersReceivedInvocations: [(isNewAuth: Bool, parameters: LoginParametersEntity)] = []
    public var executeIsNewAuthParametersReturnValue: AccessTokensEntity!
    public var executeIsNewAuthParametersClosure: ((Bool, LoginParametersEntity) async throws -> AccessTokensEntity)?

    public func execute(isNewAuth: Bool, parameters: LoginParametersEntity) async throws -> AccessTokensEntity {
        if let error = executeIsNewAuthParametersThrowableError {
            throw error
        }
        executeIsNewAuthParametersCallsCount += 1
        executeIsNewAuthParametersReceivedArguments = (isNewAuth: isNewAuth, parameters: parameters)
        executeIsNewAuthParametersReceivedInvocations.append((isNewAuth: isNewAuth, parameters: parameters))
        if let executeIsNewAuthParametersClosure = executeIsNewAuthParametersClosure {
            return try await executeIsNewAuthParametersClosure(isNewAuth, parameters)
        } else {
            return executeIsNewAuthParametersReturnValue
        }
    }

}
