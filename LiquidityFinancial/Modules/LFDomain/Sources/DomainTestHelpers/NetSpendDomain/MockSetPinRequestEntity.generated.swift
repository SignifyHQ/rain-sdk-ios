// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockSetPinRequestEntity: SetPinRequestEntity {

    public init() {}

    public var verifyId: String {
        get { return underlyingVerifyId }
        set(value) { underlyingVerifyId = value }
    }
    public var underlyingVerifyId: String!
    public var encryptedData: String {
        get { return underlyingEncryptedData }
        set(value) { underlyingEncryptedData = value }
    }
    public var underlyingEncryptedData: String!

}
