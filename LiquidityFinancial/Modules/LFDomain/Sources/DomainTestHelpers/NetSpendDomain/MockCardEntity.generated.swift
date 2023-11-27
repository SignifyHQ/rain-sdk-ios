// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockCardEntity: NSCardEntity {

    public init() {}

    public var id: String {
        get { return underlyingId }
        set(value) { underlyingId = value }
    }
    public var underlyingId: String!
    public var expirationMonth: Int {
        get { return underlyingExpirationMonth }
        set(value) { underlyingExpirationMonth = value }
    }
    public var underlyingExpirationMonth: Int!
    public var expirationYear: Int {
        get { return underlyingExpirationYear }
        set(value) { underlyingExpirationYear = value }
    }
    public var underlyingExpirationYear: Int!
    public var panLast4: String {
        get { return underlyingPanLast4 }
        set(value) { underlyingPanLast4 = value }
    }
    public var underlyingPanLast4: String!
    public var encryptedData: String?
    public var type: String {
        get { return underlyingType }
        set(value) { underlyingType = value }
    }
    public var underlyingType: String!
    public var status: String {
        get { return underlyingStatus }
        set(value) { underlyingStatus = value }
    }
    public var underlyingStatus: String!
    public var statusReason: String {
        get { return underlyingStatusReason }
        set(value) { underlyingStatusReason = value }
    }
    public var underlyingStatusReason: String!
    public var lockStatus: String {
        get { return underlyingLockStatus }
        set(value) { underlyingLockStatus = value }
    }
    public var underlyingLockStatus: String!
    public var unlockTime: String?
    public var shippingAddressEntity: ShippingAddressEntity?

}
