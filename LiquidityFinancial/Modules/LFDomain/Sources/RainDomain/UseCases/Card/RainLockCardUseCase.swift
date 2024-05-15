import Foundation

public class RainLockCardUseCase: RainLockCardUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> RainCardEntity {
    try await repository.lockCard(cardID: cardID)
  }
}
