// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockVerifyCVVCodeParametersEntity: VerifyCVVCodeParametersEntity {

    public init() {}

    public var verificationType: String {
        get { return underlyingVerificationType }
        set(value) { underlyingVerificationType = value }
    }
    public var underlyingVerificationType: String!
    public var encryptedData: String {
        get { return underlyingEncryptedData }
        set(value) { underlyingEncryptedData = value }
    }
    public var underlyingEncryptedData: String!

}
