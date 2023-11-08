// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockExternalCardExpirationEntity: ExternalCardExpirationEntity {

    public init() {}

    public var month: String {
        get { return underlyingMonth }
        set(value) { underlyingMonth = value }
    }
    public var underlyingMonth: String!
    public var year: String {
        get { return underlyingYear }
        set(value) { underlyingYear = value }
    }
    public var underlyingYear: String!

}
