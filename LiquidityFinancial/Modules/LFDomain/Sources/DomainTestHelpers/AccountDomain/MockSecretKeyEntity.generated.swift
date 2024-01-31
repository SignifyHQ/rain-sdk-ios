// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockSecretKeyEntity: SecretKeyEntity {

    public init() {}

    public var secretKey: String {
        get { return underlyingSecretKey }
        set(value) { underlyingSecretKey = value }
    }
    public var underlyingSecretKey: String!

}
