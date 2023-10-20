// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidContactEntity: SolidContactEntity {

    public init() {}

    public var name: String?
    public var last4: String {
        get { return underlyingLast4 }
        set(value) { underlyingLast4 = value }
    }
    public var underlyingLast4: String!
    public var type: String {
        get { return underlyingType }
        set(value) { underlyingType = value }
    }
    public var underlyingType: String!
    public var solidContactId: String {
        get { return underlyingSolidContactId }
        set(value) { underlyingSolidContactId = value }
    }
    public var underlyingSolidContactId: String!

}
