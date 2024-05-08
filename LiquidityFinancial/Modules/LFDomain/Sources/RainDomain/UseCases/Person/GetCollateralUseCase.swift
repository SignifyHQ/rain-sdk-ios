import Foundation

public class GetCollateralUseCase: GetCollateralUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(repository: RainRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> RainCollateralContractEntity {
    try await repository.getCollateralContract()
  }
}
