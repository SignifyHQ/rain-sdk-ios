import Foundation

public class NSUnLockCardUseCase: NSUnLockCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.unlockCard(cardID: cardID, sessionID: sessionID)
  }
}
