// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import OnboardingData

public class MockOnboardingAPIProtocol: OnboardingAPIProtocol {

    public init() {}


    //MARK: - login

    public var loginPhoneNumberOtpCodeLastIDThrowableError: Error?
    public var loginPhoneNumberOtpCodeLastIDCallsCount = 0
    public var loginPhoneNumberOtpCodeLastIDCalled: Bool {
        return loginPhoneNumberOtpCodeLastIDCallsCount > 0
    }
    public var loginPhoneNumberOtpCodeLastIDReceivedArguments: (phoneNumber: String, otpCode: String, lastID: String)?
    public var loginPhoneNumberOtpCodeLastIDReceivedInvocations: [(phoneNumber: String, otpCode: String, lastID: String)] = []
    public var loginPhoneNumberOtpCodeLastIDReturnValue: APIAccessTokens!
    public var loginPhoneNumberOtpCodeLastIDClosure: ((String, String, String) async throws -> APIAccessTokens)?

    public func login(phoneNumber: String, otpCode: String, lastID: String) async throws -> APIAccessTokens {
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
    public var requestOTPPhoneNumberReturnValue: APIOtp!
    public var requestOTPPhoneNumberClosure: ((String) async throws -> APIOtp)?

    public func requestOTP(phoneNumber: String) async throws -> APIOtp {
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
