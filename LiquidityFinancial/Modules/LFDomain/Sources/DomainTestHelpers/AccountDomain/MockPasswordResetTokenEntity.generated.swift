// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockPasswordResetTokenEntity: PasswordResetTokenEntity {

    public init() {}

    public var token: String {
        get { return underlyingToken }
        set(value) { underlyingToken = value }
    }
    public var underlyingToken: String!

}
