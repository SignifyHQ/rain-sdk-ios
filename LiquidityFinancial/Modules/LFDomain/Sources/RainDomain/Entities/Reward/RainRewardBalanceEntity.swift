import Foundation

// sourcery: AutoMockable
public protocol RainRewardBalanceEntity {
  var rewardedAmount: Double { get }
  var unprocessedAmount: Double { get }
}
