// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockLFAccount: LFAccount {

    public init() {}

    public var id: String {
        get { return underlyingId }
        set(value) { underlyingId = value }
    }
    public var underlyingId: String!
    public var externalAccountId: String?
    public var currency: String {
        get { return underlyingCurrency }
        set(value) { underlyingCurrency = value }
    }
    public var underlyingCurrency: String!
    public var availableBalance: Double {
        get { return underlyingAvailableBalance }
        set(value) { underlyingAvailableBalance = value }
    }
    public var underlyingAvailableBalance: Double!
    public var availableUsdBalance: Double {
        get { return underlyingAvailableUsdBalance }
        set(value) { underlyingAvailableUsdBalance = value }
    }
    public var underlyingAvailableUsdBalance: Double!

    //MARK: - init

    public var initIdExternalAccountIdCurrencyAvailableBalanceAvailableUsdBalanceReceivedArguments: (id: String, externalAccountId: String?, currency: String, availableBalance: Double, availableUsdBalance: Double)?
    public var initIdExternalAccountIdCurrencyAvailableBalanceAvailableUsdBalanceReceivedInvocations: [(id: String, externalAccountId: String?, currency: String, availableBalance: Double, availableUsdBalance: Double)] = []
    public var initIdExternalAccountIdCurrencyAvailableBalanceAvailableUsdBalanceClosure: ((String, String?, String, Double, Double) -> Void)?

    public required init(id: String, externalAccountId: String?, currency: String, availableBalance: Double, availableUsdBalance: Double) {
        initIdExternalAccountIdCurrencyAvailableBalanceAvailableUsdBalanceReceivedArguments = (id: id, externalAccountId: externalAccountId, currency: currency, availableBalance: availableBalance, availableUsdBalance: availableUsdBalance)
        initIdExternalAccountIdCurrencyAvailableBalanceAvailableUsdBalanceReceivedInvocations.append((id: id, externalAccountId: externalAccountId, currency: currency, availableBalance: availableBalance, availableUsdBalance: availableUsdBalance))
        initIdExternalAccountIdCurrencyAvailableBalanceAvailableUsdBalanceClosure?(id, externalAccountId, currency, availableBalance, availableUsdBalance)
    }
}
