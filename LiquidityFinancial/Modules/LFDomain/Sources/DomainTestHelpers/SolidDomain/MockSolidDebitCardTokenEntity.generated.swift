// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidDebitCardTokenEntity: SolidDebitCardTokenEntity {

    public init() {}

    public var linkToken: String {
        get { return underlyingLinkToken }
        set(value) { underlyingLinkToken = value }
    }
    public var underlyingLinkToken: String!
    public var solidContactId: String {
        get { return underlyingSolidContactId }
        set(value) { underlyingSolidContactId = value }
    }
    public var underlyingSolidContactId: String!

}
