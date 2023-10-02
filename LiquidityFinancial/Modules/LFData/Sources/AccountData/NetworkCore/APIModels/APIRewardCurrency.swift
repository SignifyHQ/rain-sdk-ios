import Foundation
import AccountDomain

public struct APIRewardCurrency: Decodable, RewardCurrencyEntity {
  public let rewardCurrency: String
}
