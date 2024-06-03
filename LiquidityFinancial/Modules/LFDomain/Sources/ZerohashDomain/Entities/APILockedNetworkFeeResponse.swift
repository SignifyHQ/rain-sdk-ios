import Foundation

public struct APILockedNetworkFeeResponse: Codable {
  public var quoteId: String
  public var amount: Double
  public var usdAmount: Double?
  public var maxAmount: Bool
  public var fee: Double
  public var usdFeeAmount: Double?
  public var netAmount: Double?
  public var netUsdAmount: Double?
  
  public init(
    quoteId: String,
    amount: Double,
    usdAmount: Double? = nil,
    maxAmount: Bool,
    fee: Double,
    usdFeeAmount: Double? = nil,
    netAmount: Double? = nil,
    netUsdAmount: Double? = nil
  ) {
    self.quoteId = quoteId
    self.amount = amount
    self.usdAmount = usdAmount
    self.maxAmount = maxAmount
    self.fee = fee
    self.usdFeeAmount = usdFeeAmount
    self.netAmount = netAmount
    self.netUsdAmount = netUsdAmount
  }
}
