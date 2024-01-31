// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain
import OnboardingDomain

public class MockOnboardingRepositoryProtocol: OnboardingRepositoryProtocol {

    public init() {}


    //MARK: - login

    public var loginParametersThrowableError: Error?
    public var loginParametersCallsCount = 0
    public var loginParametersCalled: Bool {
        return loginParametersCallsCount > 0
    }
    public var loginParametersReceivedParameters: LoginParametersEntity?
    public var loginParametersReceivedInvocations: [LoginParametersEntity] = []
    public var loginParametersReturnValue: AccessTokensEntity!
    public var loginParametersClosure: ((LoginParametersEntity) async throws -> AccessTokensEntity)?

    public func login(parameters: LoginParametersEntity) async throws -> AccessTokensEntity {
        if let error = loginParametersThrowableError {
            throw error
        }
        loginParametersCallsCount += 1
        loginParametersReceivedParameters = parameters
        loginParametersReceivedInvocations.append(parameters)
        if let loginParametersClosure = loginParametersClosure {
            return try await loginParametersClosure(parameters)
        } else {
            return loginParametersReturnValue
        }
    }

    //MARK: - newLogin

    public var newLoginParametersThrowableError: Error?
    public var newLoginParametersCallsCount = 0
    public var newLoginParametersCalled: Bool {
        return newLoginParametersCallsCount > 0
    }
    public var newLoginParametersReceivedParameters: LoginParametersEntity?
    public var newLoginParametersReceivedInvocations: [LoginParametersEntity] = []
    public var newLoginParametersReturnValue: AccessTokensEntity!
    public var newLoginParametersClosure: ((LoginParametersEntity) async throws -> AccessTokensEntity)?

    public func newLogin(parameters: LoginParametersEntity) async throws -> AccessTokensEntity {
        if let error = newLoginParametersThrowableError {
            throw error
        }
        newLoginParametersCallsCount += 1
        newLoginParametersReceivedParameters = parameters
        newLoginParametersReceivedInvocations.append(parameters)
        if let newLoginParametersClosure = newLoginParametersClosure {
            return try await newLoginParametersClosure(parameters)
        } else {
            return newLoginParametersReturnValue
        }
    }

    //MARK: - requestOTP

    public var requestOTPParametersThrowableError: Error?
    public var requestOTPParametersCallsCount = 0
    public var requestOTPParametersCalled: Bool {
        return requestOTPParametersCallsCount > 0
    }
    public var requestOTPParametersReceivedParameters: OTPParametersEntity?
    public var requestOTPParametersReceivedInvocations: [OTPParametersEntity] = []
    public var requestOTPParametersReturnValue: OtpEntity!
    public var requestOTPParametersClosure: ((OTPParametersEntity) async throws -> OtpEntity)?

    public func requestOTP(parameters: OTPParametersEntity) async throws -> OtpEntity {
        if let error = requestOTPParametersThrowableError {
            throw error
        }
        requestOTPParametersCallsCount += 1
        requestOTPParametersReceivedParameters = parameters
        requestOTPParametersReceivedInvocations.append(parameters)
        if let requestOTPParametersClosure = requestOTPParametersClosure {
            return try await requestOTPParametersClosure(parameters)
        } else {
            return requestOTPParametersReturnValue
        }
    }

    //MARK: - newRequestOTP

    public var newRequestOTPParametersThrowableError: Error?
    public var newRequestOTPParametersCallsCount = 0
    public var newRequestOTPParametersCalled: Bool {
        return newRequestOTPParametersCallsCount > 0
    }
    public var newRequestOTPParametersReceivedParameters: OTPParametersEntity?
    public var newRequestOTPParametersReceivedInvocations: [OTPParametersEntity] = []
    public var newRequestOTPParametersReturnValue: OtpEntity!
    public var newRequestOTPParametersClosure: ((OTPParametersEntity) async throws -> OtpEntity)?

    public func newRequestOTP(parameters: OTPParametersEntity) async throws -> OtpEntity {
        if let error = newRequestOTPParametersThrowableError {
            throw error
        }
        newRequestOTPParametersCallsCount += 1
        newRequestOTPParametersReceivedParameters = parameters
        newRequestOTPParametersReceivedInvocations.append(parameters)
        if let newRequestOTPParametersClosure = newRequestOTPParametersClosure {
            return try await newRequestOTPParametersClosure(parameters)
        } else {
            return newRequestOTPParametersReturnValue
        }
    }

    //MARK: - getOnboardingProcess

    public var getOnboardingProcessThrowableError: Error?
    public var getOnboardingProcessCallsCount = 0
    public var getOnboardingProcessCalled: Bool {
        return getOnboardingProcessCallsCount > 0
    }
    public var getOnboardingProcessReturnValue: OnboardingProcess!
    public var getOnboardingProcessClosure: (() async throws -> OnboardingProcess)?

    public func getOnboardingProcess() async throws -> OnboardingProcess {
        if let error = getOnboardingProcessThrowableError {
            throw error
        }
        getOnboardingProcessCallsCount += 1
        if let getOnboardingProcessClosure = getOnboardingProcessClosure {
            return try await getOnboardingProcessClosure()
        } else {
            return getOnboardingProcessReturnValue
        }
    }

}
