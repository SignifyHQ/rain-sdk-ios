// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockShippingAddressEntity: ShippingAddressEntity {

    public init() {}

    public var shippingStatus: String {
        get { return underlyingShippingStatus }
        set(value) { underlyingShippingStatus = value }
    }
    public var underlyingShippingStatus: String!
    public var shipmentDate: String?
    public var estimatedArrivalDate: String?
    public var trackingNumber: String?
    public var shippingVendor: String?

}
