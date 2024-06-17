import Foundation
import NetworkUtilities
import RainDomain

public struct APIRainRewardWithdrawalParameters: Parameterable, RainRewardWithdrawalParametersEntity {
  public let amount: Double
  public let currency: String
  public let recipientAddress: String
  
  public init(amount: Double, currency: String, recipientAddress: String) {
    self.amount = amount
    self.currency = currency
    self.recipientAddress = recipientAddress
  }
}
