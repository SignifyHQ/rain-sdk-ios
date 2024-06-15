import Foundation

public class RainGetRewardBalanceUseCase: RainGetRewardBalanceUseCaseProtocol {
  
  private let repository: RainRewardRepositoryProtocol
  
  public init(repository: RainRewardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> RainRewardBalancesEntity {
    try await repository.getRewardBalance()
  }
}
