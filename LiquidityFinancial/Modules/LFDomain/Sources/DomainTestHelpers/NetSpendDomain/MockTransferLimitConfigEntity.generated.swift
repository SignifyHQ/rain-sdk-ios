// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockTransferLimitConfigEntity: TransferLimitConfigEntity {

    public init() {}

    public var userId: String?
    public var productId: String?
    public var period: String?
    public var transferType: String?
    public var priority: Int {
        get { return underlyingPriority }
        set(value) { underlyingPriority = value }
    }
    public var underlyingPriority: Int!
    public var amount: Double {
        get { return underlyingAmount }
        set(value) { underlyingAmount = value }
    }
    public var underlyingAmount: Double!
    public var transferredAmount: Double?
    public var type: String {
        get { return underlyingType }
        set(value) { underlyingType = value }
    }
    public var underlyingType: String!
    public var createdAt: String?
    public var updatedAt: String?

}
