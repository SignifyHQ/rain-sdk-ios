import Foundation

// sourcery: AutoMockable
public protocol RainRewardRepositoryProtocol {
  func getRewardBalance() async throws -> RainRewardBalanceEntity
}
