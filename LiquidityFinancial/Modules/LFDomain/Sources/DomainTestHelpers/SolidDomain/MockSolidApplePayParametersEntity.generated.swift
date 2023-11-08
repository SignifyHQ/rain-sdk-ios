// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidApplePayParametersEntity: SolidApplePayParametersEntity {

    public init() {}

    public var deviceCert: String {
        get { return underlyingDeviceCert }
        set(value) { underlyingDeviceCert = value }
    }
    public var underlyingDeviceCert: String!
    public var nonceSignature: String {
        get { return underlyingNonceSignature }
        set(value) { underlyingNonceSignature = value }
    }
    public var underlyingNonceSignature: String!
    public var nonce: String {
        get { return underlyingNonce }
        set(value) { underlyingNonce = value }
    }
    public var underlyingNonce: String!

}
