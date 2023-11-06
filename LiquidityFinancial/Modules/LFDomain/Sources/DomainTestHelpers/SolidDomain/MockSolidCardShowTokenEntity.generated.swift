// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidCardShowTokenEntity: SolidCardShowTokenEntity {

    public init() {}

    public var solidCardId: String {
        get { return underlyingSolidCardId }
        set(value) { underlyingSolidCardId = value }
    }
    public var underlyingSolidCardId: String!
    public var showToken: String {
        get { return underlyingShowToken }
        set(value) { underlyingShowToken = value }
    }
    public var underlyingShowToken: String!

}
