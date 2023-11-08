// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockGetStatementParameterEntity: GetStatementParameterEntity {

    public init() {}

    public var fromMonth: String {
        get { return underlyingFromMonth }
        set(value) { underlyingFromMonth = value }
    }
    public var underlyingFromMonth: String!
    public var fromYear: String {
        get { return underlyingFromYear }
        set(value) { underlyingFromYear = value }
    }
    public var underlyingFromYear: String!
    public var toMonth: String {
        get { return underlyingToMonth }
        set(value) { underlyingToMonth = value }
    }
    public var underlyingToMonth: String!
    public var toYear: String {
        get { return underlyingToYear }
        set(value) { underlyingToYear = value }
    }
    public var underlyingToYear: String!

}
