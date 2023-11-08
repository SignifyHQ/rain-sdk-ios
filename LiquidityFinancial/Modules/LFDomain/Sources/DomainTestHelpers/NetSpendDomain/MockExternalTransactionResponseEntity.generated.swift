// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockExternalTransactionResponseEntity: ExternalTransactionResponseEntity {

    public init() {}

    public var transactionId: String {
        get { return underlyingTransactionId }
        set(value) { underlyingTransactionId = value }
    }
    public var underlyingTransactionId: String!
    public var externalTransferId: String {
        get { return underlyingExternalTransferId }
        set(value) { underlyingExternalTransferId = value }
    }
    public var underlyingExternalTransferId: String!

}
