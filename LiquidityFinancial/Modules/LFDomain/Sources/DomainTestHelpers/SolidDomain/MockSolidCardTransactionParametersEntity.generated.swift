// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain
import AccountDomain

public class MockSolidCardTransactionParametersEntity: SolidCardTransactionParametersEntity {

    public init() {}

    public var cardId: String {
        get { return underlyingCardId }
        set(value) { underlyingCardId = value }
    }
    public var underlyingCardId: String!
    public var currencyType: String {
        get { return underlyingCurrencyType }
        set(value) { underlyingCurrencyType = value }
    }
    public var underlyingCurrencyType: String!
    public var transactionTypes: [String] = []
    public var limit: Int {
        get { return underlyingLimit }
        set(value) { underlyingLimit = value }
    }
    public var underlyingLimit: Int!
    public var offset: Int {
        get { return underlyingOffset }
        set(value) { underlyingOffset = value }
    }
    public var underlyingOffset: Int!

}
