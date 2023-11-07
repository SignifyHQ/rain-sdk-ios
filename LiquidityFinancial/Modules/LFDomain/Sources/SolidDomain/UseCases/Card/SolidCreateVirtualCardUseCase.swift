import Foundation
  
public class SolidCreateVirtualCardUseCase: SolidCreateVirtualCardUseCaseProtocol {
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountID: String) async throws -> SolidCardEntity {
    try await self.repository.createVirtualCard(accountID: accountID)
  }
}
