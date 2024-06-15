import Foundation

// sourcery: AutoMockable
public protocol RainRewardRepositoryProtocol {
  func getRewardBalance() async throws -> RainRewardBalancesEntity
  func requestRewardWithdrawal(parameters: RainRewardWithdrawalParametersEntity) async throws
}
