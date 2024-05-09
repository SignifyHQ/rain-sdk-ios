import Foundation

public class GetCreditBalanceUseCase: GetCreditBalanceUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(repository: RainRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> RainCreditBalanceEntity {
    try await repository.getCreditBalance()
  }
}
