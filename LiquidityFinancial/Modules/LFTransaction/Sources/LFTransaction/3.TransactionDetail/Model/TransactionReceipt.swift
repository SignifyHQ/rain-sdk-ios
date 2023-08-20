import Foundation

public struct TransactionReceipt {
  public var type: String
  public var id: String
  public var accountId: String
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

  public init(
    type: String,
    id: String,
    accountId: String,
    fee: Double? = nil,
    completedAt: String? = nil,
    tradingPair: String? = nil,
    currency: String? = nil,
    orderType: String? = nil,
    size: Double? = nil,
    exchangeRate: Double? = nil,
    transactionValue: Double? = nil,
    rewardsDonation: Double? = nil,
    roundUpDonation: Double? = nil,
    oneTimeDonation: Double? = nil,
    totalDonation: Double? = nil
  ) {
    self.type = type
    self.id = id
    self.accountId = accountId
    self.fee = fee
    self.completedAt = completedAt
    self.tradingPair = tradingPair
    self.currency = currency
    self.orderType = orderType
    self.size = size
    self.exchangeRate = exchangeRate
    self.transactionValue = transactionValue
    self.rewardsDonation = rewardsDonation
    self.roundUpDonation = roundUpDonation
    self.oneTimeDonation = oneTimeDonation
    self.totalDonation = totalDonation
  }
}
