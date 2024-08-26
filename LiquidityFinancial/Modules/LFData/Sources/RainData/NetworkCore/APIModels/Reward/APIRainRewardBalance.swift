import Foundation
import RainDomain

public struct APIRainRewardBalances: RainRewardBalancesEntity {
  public let data: [RainRewardBalanceEntity]
}

public struct APIRainRewardBalance: Codable, RainRewardBalanceEntity {
  public let rewardedAmount: Double
  public let unprocessedAmount: Double
  public let lockedAmount: Double
}
