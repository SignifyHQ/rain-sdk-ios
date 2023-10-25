import Foundation

public class NSLockCardUseCase: NSLockCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.lockCard(cardID: cardID, sessionID: sessionID)
  }
}
