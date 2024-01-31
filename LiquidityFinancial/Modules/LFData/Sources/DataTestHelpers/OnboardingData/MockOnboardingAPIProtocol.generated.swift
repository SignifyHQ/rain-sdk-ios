// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import OnboardingData

public class MockOnboardingAPIProtocol: OnboardingAPIProtocol {

    public init() {}


    //MARK: - login

    public var loginParametersThrowableError: Error?
    public var loginParametersCallsCount = 0
    public var loginParametersCalled: Bool {
        return loginParametersCallsCount > 0
    }
    public var loginParametersReceivedParameters: LoginParameters?
    public var loginParametersReceivedInvocations: [LoginParameters] = []
    public var loginParametersReturnValue: APIAccessTokens!
    public var loginParametersClosure: ((LoginParameters) async throws -> APIAccessTokens)?

    public func login(parameters: LoginParameters) async throws -> APIAccessTokens {
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
    public var newLoginParametersReceivedParameters: LoginParameters?
    public var newLoginParametersReceivedInvocations: [LoginParameters] = []
    public var newLoginParametersReturnValue: APIAccessTokens!
    public var newLoginParametersClosure: ((LoginParameters) async throws -> APIAccessTokens)?

    public func newLogin(parameters: LoginParameters) async throws -> APIAccessTokens {
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
    public var requestOTPParametersReceivedParameters: OTPParameters?
    public var requestOTPParametersReceivedInvocations: [OTPParameters] = []
    public var requestOTPParametersReturnValue: APIOtp!
    public var requestOTPParametersClosure: ((OTPParameters) async throws -> APIOtp)?

    public func requestOTP(parameters: OTPParameters) async throws -> APIOtp {
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
    public var newRequestOTPParametersReceivedParameters: OTPParameters?
    public var newRequestOTPParametersReceivedInvocations: [OTPParameters] = []
    public var newRequestOTPParametersReturnValue: APIOtp!
    public var newRequestOTPParametersClosure: ((OTPParameters) async throws -> APIOtp)?

    public func newRequestOTP(parameters: OTPParameters) async throws -> APIOtp {
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

    //MARK: - refreshToken

    public var refreshTokenTokenThrowableError: Error?
    public var refreshTokenTokenCallsCount = 0
    public var refreshTokenTokenCalled: Bool {
        return refreshTokenTokenCallsCount > 0
    }
    public var refreshTokenTokenReceivedToken: String?
    public var refreshTokenTokenReceivedInvocations: [String] = []
    public var refreshTokenTokenReturnValue: Bool!
    public var refreshTokenTokenClosure: ((String) async throws -> Bool)?

    public func refreshToken(token: String) async throws -> Bool {
        if let error = refreshTokenTokenThrowableError {
            throw error
        }
        refreshTokenTokenCallsCount += 1
        refreshTokenTokenReceivedToken = token
        refreshTokenTokenReceivedInvocations.append(token)
        if let refreshTokenTokenClosure = refreshTokenTokenClosure {
            return try await refreshTokenTokenClosure(token)
        } else {
            return refreshTokenTokenReturnValue
        }
    }

    //MARK: - getOnboardingProcess

    public var getOnboardingProcessThrowableError: Error?
    public var getOnboardingProcessCallsCount = 0
    public var getOnboardingProcessCalled: Bool {
        return getOnboardingProcessCallsCount > 0
    }
    public var getOnboardingProcessReturnValue: APIOnboardingProcess!
    public var getOnboardingProcessClosure: (() async throws -> APIOnboardingProcess)?

    public func getOnboardingProcess() async throws -> APIOnboardingProcess {
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
