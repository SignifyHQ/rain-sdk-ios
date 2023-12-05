import Foundation
  
public class SolidCancelACHTransactionUseCase: SolidCancelACHTransactionUseCaseProtocol {
  
  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(liquidityTransactionID: String) async throws -> SolidExternalTransactionResponseEntity {
    try await repository.cancelACHTransaction(liquidityTransactionID: liquidityTransactionID)
  }
  
}
