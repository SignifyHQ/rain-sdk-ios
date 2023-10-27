// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidWireTransferResponseEntity: SolidWireTransferResponseEntity {

    public init() {}

    public var accountNumber: String {
        get { return underlyingAccountNumber }
        set(value) { underlyingAccountNumber = value }
    }
    public var underlyingAccountNumber: String!
    public var routingNumber: String {
        get { return underlyingRoutingNumber }
        set(value) { underlyingRoutingNumber = value }
    }
    public var underlyingRoutingNumber: String!

}
