import Foundation

// sourcery: AutoMockable
public protocol RainRewardAPIProtocol {
  func getRewardBalance() async throws -> APIRainRewardBalance
  func requestRewardWithdrawal(parameters: APIRainRewardWithdrawalParameters) async throws
}
