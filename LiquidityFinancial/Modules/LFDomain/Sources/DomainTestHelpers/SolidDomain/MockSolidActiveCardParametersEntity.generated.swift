// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidActiveCardParametersEntity: SolidActiveCardParametersEntity {

    public init() {}

    public var expiryMonth: String {
        get { return underlyingExpiryMonth }
        set(value) { underlyingExpiryMonth = value }
    }
    public var underlyingExpiryMonth: String!
    public var expiryYear: String {
        get { return underlyingExpiryYear }
        set(value) { underlyingExpiryYear = value }
    }
    public var underlyingExpiryYear: String!
    public var last4: String {
        get { return underlyingLast4 }
        set(value) { underlyingLast4 = value }
    }
    public var underlyingLast4: String!

}
