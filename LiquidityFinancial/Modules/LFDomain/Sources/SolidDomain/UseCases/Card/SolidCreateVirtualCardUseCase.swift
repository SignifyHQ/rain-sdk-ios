import Foundation
  
public class SolidCreateVirtualCardUseCase: SolidCreateVirtualCardUseCaseProtocol {
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    accountID: String,
    parameters: SolidCreateVirtualCardParametersEntity
  ) async throws -> SolidCardEntity {
    try await self.repository.createVirtualCard(accountID: accountID, parameters: parameters)
  }
}
