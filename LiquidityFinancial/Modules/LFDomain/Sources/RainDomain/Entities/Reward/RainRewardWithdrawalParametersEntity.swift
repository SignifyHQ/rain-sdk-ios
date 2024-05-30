import Foundation

// sourcery: AutoMockable
public protocol RainRewardWithdrawalParametersEntity {
  var amount: Double { get }
  var recipientAddress: String { get }
}
