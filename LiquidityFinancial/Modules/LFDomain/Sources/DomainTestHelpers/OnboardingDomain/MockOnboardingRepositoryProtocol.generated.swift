// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain
import OnboardingDomain

public class MockOnboardingRepositoryProtocol: OnboardingRepositoryProtocol {

    public init() {}


    //MARK: - login

    public var loginPhoneNumberOtpCodeLastIDThrowableError: Error?
    public var loginPhoneNumberOtpCodeLastIDCallsCount = 0
    public var loginPhoneNumberOtpCodeLastIDCalled: Bool {
        return loginPhoneNumberOtpCodeLastIDCallsCount > 0
    }
    public var loginPhoneNumberOtpCodeLastIDReceivedArguments: (phoneNumber: String, otpCode: String, lastID: String)?
    public var loginPhoneNumberOtpCodeLastIDReceivedInvocations: [(phoneNumber: String, otpCode: String, lastID: String)] = []
    public var loginPhoneNumberOtpCodeLastIDReturnValue: AccessTokensEntity!
    public var loginPhoneNumberOtpCodeLastIDClosure: ((String, String, String) async throws -> AccessTokensEntity)?

    public func login(phoneNumber: String, otpCode: String, lastID: String) async throws -> AccessTokensEntity {
        if let error = loginPhoneNumberOtpCodeLastIDThrowableError {
            throw error
        }
        loginPhoneNumberOtpCodeLastIDCallsCount += 1
        loginPhoneNumberOtpCodeLastIDReceivedArguments = (phoneNumber: phoneNumber, otpCode: otpCode, lastID: lastID)
        loginPhoneNumberOtpCodeLastIDReceivedInvocations.append((phoneNumber: phoneNumber, otpCode: otpCode, lastID: lastID))
        if let loginPhoneNumberOtpCodeLastIDClosure = loginPhoneNumberOtpCodeLastIDClosure {
            return try await loginPhoneNumberOtpCodeLastIDClosure(phoneNumber, otpCode, lastID)
        } else {
            return loginPhoneNumberOtpCodeLastIDReturnValue
        }
    }

    //MARK: - requestOTP

    public var requestOTPPhoneNumberThrowableError: Error?
    public var requestOTPPhoneNumberCallsCount = 0
    public var requestOTPPhoneNumberCalled: Bool {
        return requestOTPPhoneNumberCallsCount > 0
    }
    public var requestOTPPhoneNumberReceivedPhoneNumber: String?
    public var requestOTPPhoneNumberReceivedInvocations: [String] = []
    public var requestOTPPhoneNumberReturnValue: OtpEntity!
    public var requestOTPPhoneNumberClosure: ((String) async throws -> OtpEntity)?

    public func requestOTP(phoneNumber: String) async throws -> OtpEntity {
        if let error = requestOTPPhoneNumberThrowableError {
            throw error
        }
        requestOTPPhoneNumberCallsCount += 1
        requestOTPPhoneNumberReceivedPhoneNumber = phoneNumber
        requestOTPPhoneNumberReceivedInvocations.append(phoneNumber)
        if let requestOTPPhoneNumberClosure = requestOTPPhoneNumberClosure {
            return try await requestOTPPhoneNumberClosure(phoneNumber)
        } else {
            return requestOTPPhoneNumberReturnValue
        }
    }

    //MARK: - onboardingState

    public var onboardingStateSessionIdThrowableError: Error?
    public var onboardingStateSessionIdCallsCount = 0
    public var onboardingStateSessionIdCalled: Bool {
        return onboardingStateSessionIdCallsCount > 0
    }
    public var onboardingStateSessionIdReceivedSessionId: String?
    public var onboardingStateSessionIdReceivedInvocations: [String] = []
    public var onboardingStateSessionIdReturnValue: OnboardingStateEnity!
    public var onboardingStateSessionIdClosure: ((String) async throws -> OnboardingStateEnity)?

    public func onboardingState(sessionId: String) async throws -> OnboardingStateEnity {
        if let error = onboardingStateSessionIdThrowableError {
            throw error
        }
        onboardingStateSessionIdCallsCount += 1
        onboardingStateSessionIdReceivedSessionId = sessionId
        onboardingStateSessionIdReceivedInvocations.append(sessionId)
        if let onboardingStateSessionIdClosure = onboardingStateSessionIdClosure {
            return try await onboardingStateSessionIdClosure(sessionId)
        } else {
            return onboardingStateSessionIdReturnValue
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
