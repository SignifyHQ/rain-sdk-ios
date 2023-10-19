// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockAvailableRewardCurrenciesEntity: AvailableRewardCurrenciesEntity {

    public init() {}

    public var availableRewardCurrencies: [String] = []

    //MARK: - init

    public var initAvailableRewardCurrenciesReceivedAvailableRewardCurrencies: [String]?
    public var initAvailableRewardCurrenciesReceivedInvocations: [[String]] = []
    public var initAvailableRewardCurrenciesClosure: (([String]) -> Void)?

    public required init(availableRewardCurrencies: [String]) {
        initAvailableRewardCurrenciesReceivedAvailableRewardCurrencies = availableRewardCurrencies
        initAvailableRewardCurrenciesReceivedInvocations.append(availableRewardCurrencies)
        initAvailableRewardCurrenciesClosure?(availableRewardCurrencies)
    }
}
