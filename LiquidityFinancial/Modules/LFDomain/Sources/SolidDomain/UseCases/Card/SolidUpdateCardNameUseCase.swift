import Foundation
  
public class SolidUpdateCardNameUseCase: SolidUpdateCardNameUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, parameters: SolidCardNameParametersEntity) async throws -> SolidCardEntity {
    try await self.repository.updateCardName(cardID: cardID, parameters: parameters)
  }
}
