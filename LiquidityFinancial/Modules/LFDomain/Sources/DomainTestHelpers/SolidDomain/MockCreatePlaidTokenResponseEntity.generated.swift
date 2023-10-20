// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockCreatePlaidTokenResponseEntity: CreatePlaidTokenResponseEntity {

    public init() {}

    public var linkToken: String {
        get { return underlyingLinkToken }
        set(value) { underlyingLinkToken = value }
    }
    public var underlyingLinkToken: String!

}
