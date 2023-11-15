import Foundation
  
public class SolidGetCardLimitsUseCase: SolidGetCardLimitsUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> SolidCardLimitsEntity {
    try await self.repository.getCardLimits(cardID: cardID)
  }
}
