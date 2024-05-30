import Foundation

// sourcery: AutoMockable
public protocol RainRewardAPIProtocol {
  func getRewardBalance() async throws -> APIRainRewardBalance
}
