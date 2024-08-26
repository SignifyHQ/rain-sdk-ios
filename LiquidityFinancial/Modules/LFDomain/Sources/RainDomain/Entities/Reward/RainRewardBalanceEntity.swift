import Foundation

// sourcery: AutoMockable
public protocol RainRewardBalancesEntity {
  var data: [RainRewardBalanceEntity] { get }
}

public protocol RainRewardBalanceEntity {
  var rewardedAmount: Double { get }
  var unprocessedAmount: Double { get }
  var lockedAmount: Double { get }
}
