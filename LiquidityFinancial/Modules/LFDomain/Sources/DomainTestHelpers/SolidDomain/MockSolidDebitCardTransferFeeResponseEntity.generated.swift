// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidDebitCardTransferFeeResponseEntity: SolidDebitCardTransferFeeResponseEntity {

    public init() {}

    public var fee: Double {
        get { return underlyingFee }
        set(value) { underlyingFee = value }
    }
    public var underlyingFee: Double!
    public var amount: Double {
        get { return underlyingAmount }
        set(value) { underlyingAmount = value }
    }
    public var underlyingAmount: Double!
    public var total: Double {
        get { return underlyingTotal }
        set(value) { underlyingTotal = value }
    }
    public var underlyingTotal: Double!

}
