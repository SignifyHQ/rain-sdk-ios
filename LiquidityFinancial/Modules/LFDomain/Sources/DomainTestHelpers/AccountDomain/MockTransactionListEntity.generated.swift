// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockTransactionListEntity: TransactionListEntity {

    public init() {}

    public var total: Int {
        get { return underlyingTotal }
        set(value) { underlyingTotal = value }
    }
    public var underlyingTotal: Int!
    public var data: [TransactionEntity] = []

}
