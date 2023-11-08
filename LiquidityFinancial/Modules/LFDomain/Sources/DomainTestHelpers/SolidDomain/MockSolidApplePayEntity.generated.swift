// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidApplePayEntity: SolidApplePayEntity {

    public init() {}

    public var paymentAccountReference: String {
        get { return underlyingPaymentAccountReference }
        set(value) { underlyingPaymentAccountReference = value }
    }
    public var underlyingPaymentAccountReference: String!
    public var activationData: String {
        get { return underlyingActivationData }
        set(value) { underlyingActivationData = value }
    }
    public var underlyingActivationData: String!
    public var encryptedPassData: String {
        get { return underlyingEncryptedPassData }
        set(value) { underlyingEncryptedPassData = value }
    }
    public var underlyingEncryptedPassData: String!
    public var ephemeralPublicKey: String {
        get { return underlyingEphemeralPublicKey }
        set(value) { underlyingEphemeralPublicKey = value }
    }
    public var underlyingEphemeralPublicKey: String!

}
