import Foundation
  
public class SolidCloseCardUseCase: SolidCloseCardUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> Bool {
    try await self.repository.closeCard(cardID: cardID)
  }
}
