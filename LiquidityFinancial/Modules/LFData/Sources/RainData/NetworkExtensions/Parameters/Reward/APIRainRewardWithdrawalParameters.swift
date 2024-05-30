import Foundation
import NetworkUtilities
import RainDomain

public struct APIRainRewardWithdrawalParameters: Parameterable, RainRewardWithdrawalParametersEntity {
  public let amount: Double
  public let recipientAddress: String
  
  public init(amount: Double, recipientAddress: String) {
    self.amount = amount
    self.recipientAddress = recipientAddress
  }
}
