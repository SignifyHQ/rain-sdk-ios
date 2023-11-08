// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockPinWheelTokenEntity: PinWheelTokenEntity {

    public init() {}

    public var id: String {
        get { return underlyingId }
        set(value) { underlyingId = value }
    }
    public var underlyingId: String!
    public var expires: String {
        get { return underlyingExpires }
        set(value) { underlyingExpires = value }
    }
    public var underlyingExpires: String!
    public var mode: String {
        get { return underlyingMode }
        set(value) { underlyingMode = value }
    }
    public var underlyingMode: String!
    public var token: String {
        get { return underlyingToken }
        set(value) { underlyingToken = value }
    }
    public var underlyingToken: String!

}
