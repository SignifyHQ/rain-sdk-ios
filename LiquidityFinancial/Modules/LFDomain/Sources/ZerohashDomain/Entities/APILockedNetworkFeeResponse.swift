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
}
