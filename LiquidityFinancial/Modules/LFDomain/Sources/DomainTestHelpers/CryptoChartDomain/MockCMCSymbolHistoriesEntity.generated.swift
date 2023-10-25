// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import CryptoChartDomain

public class MockCMCSymbolHistoriesEntity: CMCSymbolHistoriesEntity {

    public init() {}

    public var currency: String {
        get { return underlyingCurrency }
        set(value) { underlyingCurrency = value }
    }
    public var underlyingCurrency: String!
    public var interval: String {
        get { return underlyingInterval }
        set(value) { underlyingInterval = value }
    }
    public var underlyingInterval: String!
    public var timestamp: String?
    public var open: Double?
    public var close: Double?
    public var high: Double?
    public var low: Double?
    public var value: Double?
    public var volume: Double?

}
