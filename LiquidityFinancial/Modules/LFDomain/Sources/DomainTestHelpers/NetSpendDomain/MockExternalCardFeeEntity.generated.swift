// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockExternalCardFeeEntity: ExternalCardFeeEntity {

    public init() {}

    public var id: String {
        get { return underlyingId }
        set(value) { underlyingId = value }
    }
    public var underlyingId: String!
    public var currency: String {
        get { return underlyingCurrency }
        set(value) { underlyingCurrency = value }
    }
    public var underlyingCurrency: String!
    public var amount: Double {
        get { return underlyingAmount }
        set(value) { underlyingAmount = value }
    }
    public var underlyingAmount: Double!
    public var memo: String {
        get { return underlyingMemo }
        set(value) { underlyingMemo = value }
    }
    public var underlyingMemo: String!

}
