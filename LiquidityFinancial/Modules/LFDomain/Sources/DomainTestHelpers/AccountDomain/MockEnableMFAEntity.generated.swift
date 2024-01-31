// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockEnableMFAEntity: EnableMFAEntity {

    public init() {}

    public var recoveryCode: String {
        get { return underlyingRecoveryCode }
        set(value) { underlyingRecoveryCode = value }
    }
    public var underlyingRecoveryCode: String!

}
