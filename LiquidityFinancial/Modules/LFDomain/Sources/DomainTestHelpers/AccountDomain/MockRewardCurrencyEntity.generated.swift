// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockRewardCurrencyEntity: RewardCurrencyEntity {

    public init() {}

    public var rewardCurrency: String {
        get { return underlyingRewardCurrency }
        set(value) { underlyingRewardCurrency = value }
    }
    public var underlyingRewardCurrency: String!

}
