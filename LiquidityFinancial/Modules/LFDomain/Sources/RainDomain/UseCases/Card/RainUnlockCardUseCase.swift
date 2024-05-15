import Foundation

public class RainUnlockCardUseCase: RainUnlockCardUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> RainCardEntity {
    try await repository.unlockCard(cardID: cardID)
  }
}
