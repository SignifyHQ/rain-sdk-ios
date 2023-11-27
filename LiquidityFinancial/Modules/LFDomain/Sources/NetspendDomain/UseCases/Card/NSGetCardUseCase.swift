import Foundation

public class NSGetCardUseCase: NSGetCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, sessionID: String) async throws -> NSCardEntity {
    try await repository.getCard(cardID: cardID, sessionID: sessionID)
  }
}
