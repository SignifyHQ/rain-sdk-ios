import Foundation
  
public class SolidUpdateCardStatusUseCase: SolidUpdateCardStatusUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, parameters: SolidCardStatusParametersEntity) async throws -> SolidCardEntity {
    try await self.repository.updateCardStatus(cardID: cardID, parameters: parameters)
  }
}
