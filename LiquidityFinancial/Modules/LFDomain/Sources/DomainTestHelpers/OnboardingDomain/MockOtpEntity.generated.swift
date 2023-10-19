// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import OnboardingDomain

public class MockOtpEntity: OtpEntity {

    public init() {}

    public var requiredAuth: [String] = []

    //MARK: - init

    public var initRequiredAuthReceivedRequiredAuth: [String]?
    public var initRequiredAuthReceivedInvocations: [[String]] = []
    public var initRequiredAuthClosure: (([String]) -> Void)?

    public required init(requiredAuth: [String]) {
        initRequiredAuthReceivedRequiredAuth = requiredAuth
        initRequiredAuthReceivedInvocations.append(requiredAuth)
        initRequiredAuthClosure?(requiredAuth)
    }
}
