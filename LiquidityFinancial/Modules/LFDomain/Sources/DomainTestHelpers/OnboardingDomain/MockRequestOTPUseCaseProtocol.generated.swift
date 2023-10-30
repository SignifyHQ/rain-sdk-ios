// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import OnboardingDomain

public class MockRequestOTPUseCaseProtocol: RequestOTPUseCaseProtocol {

    public init() {}


    //MARK: - execute

    public var executePhoneNumberThrowableError: Error?
    public var executePhoneNumberCallsCount = 0
    public var executePhoneNumberCalled: Bool {
        return executePhoneNumberCallsCount > 0
    }
    public var executePhoneNumberReceivedPhoneNumber: String?
    public var executePhoneNumberReceivedInvocations: [String] = []
    public var executePhoneNumberReturnValue: OtpEntity!
    public var executePhoneNumberClosure: ((String) async throws -> OtpEntity)?

    public func execute(phoneNumber: String) async throws -> OtpEntity {
        if let error = executePhoneNumberThrowableError {
            throw error
        }
        executePhoneNumberCallsCount += 1
        executePhoneNumberReceivedPhoneNumber = phoneNumber
        executePhoneNumberReceivedInvocations.append(phoneNumber)
        if let executePhoneNumberClosure = executePhoneNumberClosure {
            return try await executePhoneNumberClosure(phoneNumber)
        } else {
            return executePhoneNumberReturnValue
        }
    }

}
