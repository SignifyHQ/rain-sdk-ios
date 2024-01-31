// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import OnboardingDomain

public class MockLoginParametersEntity: LoginParametersEntity {

    public init() {}

    public var phoneNumber: String {
        get { return underlyingPhoneNumber }
        set(value) { underlyingPhoneNumber = value }
    }
    public var underlyingPhoneNumber: String!
    public var code: String {
        get { return underlyingCode }
        set(value) { underlyingCode = value }
    }
    public var underlyingCode: String!
    public var lastXId: String?
    public var verificationEntity: VerificationEntity?

}
