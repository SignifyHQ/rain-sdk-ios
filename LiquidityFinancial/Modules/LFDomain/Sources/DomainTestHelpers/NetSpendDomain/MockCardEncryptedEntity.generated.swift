// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockCardEncryptedEntity: CardEncryptedEntity {

    public init() {}

    public var pan: String {
        get { return underlyingPan }
        set(value) { underlyingPan = value }
    }
    public var underlyingPan: String!
    public var cvv2: String {
        get { return underlyingCvv2 }
        set(value) { underlyingCvv2 = value }
    }
    public var underlyingCvv2: String!

}
