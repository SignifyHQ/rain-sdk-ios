import Foundation

public class NSCloseCardUseCase: NSCloseCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    reason: CloseCardReasonEntity,
    cardID: String,
    sessionID: String
  ) async throws -> NSCardEntity {
    try await repository.closeCard(reason: reason, cardID: cardID, sessionID: sessionID)
  }
}
