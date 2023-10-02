import Foundation
import NetworkUtilities
import AccountDomain

public struct RewardCurrencyParameters: Parameterable, RewardCurrencyEntity {
  public var rewardCurrency: String
  
  public init(rewardCurrency: String) {
    self.rewardCurrency = rewardCurrency
  }
}
