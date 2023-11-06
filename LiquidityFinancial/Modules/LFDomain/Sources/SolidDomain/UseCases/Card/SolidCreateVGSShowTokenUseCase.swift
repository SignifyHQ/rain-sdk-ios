import Foundation
  
public class SolidCreateVGSShowTokenUseCase: SolidCreateVGSShowTokenUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> SolidCardShowTokenEntity {
    try await self.repository.createVGSShowToken(cardID: cardID)
  }
}
