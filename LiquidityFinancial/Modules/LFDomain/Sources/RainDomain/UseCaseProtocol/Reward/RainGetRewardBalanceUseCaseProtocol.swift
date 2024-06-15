import Foundation

public protocol RainGetRewardBalanceUseCaseProtocol {
  func execute() async throws -> RainRewardBalancesEntity
}
