import Foundation

// sourcery: AutoMockable
public protocol RainRewardAPIProtocol {
  func getRewardBalance() async throws -> APIRainRewardBalances
  func requestRewardWithdrawal(parameters: APIRainRewardWithdrawalParameters) async throws
}
