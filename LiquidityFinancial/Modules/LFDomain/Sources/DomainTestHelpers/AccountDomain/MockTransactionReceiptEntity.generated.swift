// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockTransactionReceiptEntity: TransactionReceiptEntity {

    public init() {}

    public var type: String {
        get { return underlyingType }
        set(value) { underlyingType = value }
    }
    public var underlyingType: String!
    public var id: String {
        get { return underlyingId }
        set(value) { underlyingId = value }
    }
    public var underlyingId: String!
    public var accountId: String {
        get { return underlyingAccountId }
        set(value) { underlyingAccountId = value }
    }
    public var underlyingAccountId: String!
    public var fee: Double?
    public var completedAt: String?
    public var tradingPair: String?
    public var currency: String?
    public var orderType: String?
    public var size: Double?
    public var exchangeRate: Double?
    public var transactionValue: Double?
    public var rewardsDonation: Double?
    public var roundUpDonation: Double?
    public var oneTimeDonation: Double?
    public var totalDonation: Double?

    //MARK: - init

    public var initTypeIdAccountIdFeeCompletedAtTradingPairCurrencyOrderTypeSizeExchangeRateTransactionValueRewardsDonationRoundUpDonationOneTimeDonationTotalDonationReceivedArguments: (type: String, id: String, accountId: String, fee: Double?, completedAt: String?, tradingPair: String?, currency: String?, orderType: String?, size: Double?, exchangeRate: Double?, transactionValue: Double?, rewardsDonation: Double?, roundUpDonation: Double?, oneTimeDonation: Double?, totalDonation: Double?)?
    public var initTypeIdAccountIdFeeCompletedAtTradingPairCurrencyOrderTypeSizeExchangeRateTransactionValueRewardsDonationRoundUpDonationOneTimeDonationTotalDonationReceivedInvocations: [(type: String, id: String, accountId: String, fee: Double?, completedAt: String?, tradingPair: String?, currency: String?, orderType: String?, size: Double?, exchangeRate: Double?, transactionValue: Double?, rewardsDonation: Double?, roundUpDonation: Double?, oneTimeDonation: Double?, totalDonation: Double?)] = []
    public var initTypeIdAccountIdFeeCompletedAtTradingPairCurrencyOrderTypeSizeExchangeRateTransactionValueRewardsDonationRoundUpDonationOneTimeDonationTotalDonationClosure: ((String, String, String, Double?, String?, String?, String?, String?, Double?, Double?, Double?, Double?, Double?, Double?, Double?) -> Void)?

    public required init(type: String, id: String, accountId: String, fee: Double?, completedAt: String?, tradingPair: String?, currency: String?, orderType: String?, size: Double?, exchangeRate: Double?, transactionValue: Double?, rewardsDonation: Double?, roundUpDonation: Double?, oneTimeDonation: Double?, totalDonation: Double?) {
        initTypeIdAccountIdFeeCompletedAtTradingPairCurrencyOrderTypeSizeExchangeRateTransactionValueRewardsDonationRoundUpDonationOneTimeDonationTotalDonationReceivedArguments = (type: type, id: id, accountId: accountId, fee: fee, completedAt: completedAt, tradingPair: tradingPair, currency: currency, orderType: orderType, size: size, exchangeRate: exchangeRate, transactionValue: transactionValue, rewardsDonation: rewardsDonation, roundUpDonation: roundUpDonation, oneTimeDonation: oneTimeDonation, totalDonation: totalDonation)
        initTypeIdAccountIdFeeCompletedAtTradingPairCurrencyOrderTypeSizeExchangeRateTransactionValueRewardsDonationRoundUpDonationOneTimeDonationTotalDonationReceivedInvocations.append((type: type, id: id, accountId: accountId, fee: fee, completedAt: completedAt, tradingPair: tradingPair, currency: currency, orderType: orderType, size: size, exchangeRate: exchangeRate, transactionValue: transactionValue, rewardsDonation: rewardsDonation, roundUpDonation: roundUpDonation, oneTimeDonation: oneTimeDonation, totalDonation: totalDonation))
        initTypeIdAccountIdFeeCompletedAtTradingPairCurrencyOrderTypeSizeExchangeRateTransactionValueRewardsDonationRoundUpDonationOneTimeDonationTotalDonationClosure?(type, id, accountId, fee, completedAt, tradingPair, currency, orderType, size, exchangeRate, transactionValue, rewardsDonation, roundUpDonation, oneTimeDonation, totalDonation)
    }
}
