// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import OnboardingDomain

public class MockOTPParametersEntity: OTPParametersEntity {

    public init() {}

    public var phoneNumber: String {
        get { return underlyingPhoneNumber }
        set(value) { underlyingPhoneNumber = value }
    }
    public var underlyingPhoneNumber: String!

    //MARK: - init

    public var initPhoneNumberReceivedPhoneNumber: String?
    public var initPhoneNumberReceivedInvocations: [String] = []
    public var initPhoneNumberClosure: ((String) -> Void)?

    public required init(phoneNumber: String) {
        initPhoneNumberReceivedPhoneNumber = phoneNumber
        initPhoneNumberReceivedInvocations.append(phoneNumber)
        initPhoneNumberClosure?(phoneNumber)
    }
}
