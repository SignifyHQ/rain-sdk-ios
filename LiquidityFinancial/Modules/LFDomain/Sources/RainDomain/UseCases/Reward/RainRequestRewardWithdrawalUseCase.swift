import Foundation

public class RainRequestRewardWithdrawalUseCase: RainRequestRewardWithdrawalUseCaseProtocol {
  
  private let repository: RainRewardRepositoryProtocol
  
  public init(repository: RainRewardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: RainRewardWithdrawalParametersEntity) async throws {
    try await repository.requestRewardWithdrawal(parameters: parameters)
  }
}
