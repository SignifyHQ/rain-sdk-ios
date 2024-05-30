import Foundation
import RainDomain

public struct APIRainRewardBalance: Decodable, RainRewardBalanceEntity {
  public let rewardedAmount: Double
  public let unprocessedAmount: Double
}
