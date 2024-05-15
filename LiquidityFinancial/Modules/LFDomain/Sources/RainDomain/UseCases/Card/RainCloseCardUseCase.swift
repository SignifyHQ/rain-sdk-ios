import Foundation

public class RainCloseCardUseCase: RainCloseCardUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> RainCardEntity {
    try await repository.closeCard(cardID: cardID)
  }
}
