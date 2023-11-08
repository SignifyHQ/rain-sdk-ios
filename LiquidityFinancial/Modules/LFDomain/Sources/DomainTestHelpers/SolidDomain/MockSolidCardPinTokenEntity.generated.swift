// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidCardPinTokenEntity: SolidCardPinTokenEntity {

    public init() {}

    public var solidCardId: String {
        get { return underlyingSolidCardId }
        set(value) { underlyingSolidCardId = value }
    }
    public var underlyingSolidCardId: String!
    public var pinToken: String {
        get { return underlyingPinToken }
        set(value) { underlyingPinToken = value }
    }
    public var underlyingPinToken: String!

}
