import Foundation

public protocol RainRequestRewardWithdrawalUseCaseProtocol {
  func execute(parameters: RainRewardWithdrawalParametersEntity) async throws
}
