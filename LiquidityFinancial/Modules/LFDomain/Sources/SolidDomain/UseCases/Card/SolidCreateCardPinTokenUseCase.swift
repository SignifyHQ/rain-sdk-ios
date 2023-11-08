import Foundation
  
public class SolidCreateCardPinTokenUseCase: SolidCreateCardPinTokenUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> SolidCardPinTokenEntity {
    try await self.repository.createCardPinToken(cardID: cardID)
  }
}
