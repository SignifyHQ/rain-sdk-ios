import Foundation

public class NSGetApplePayTokenUseCase: NSGetApplePayTokenUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionId: String, cardId: String) async throws -> any GetApplePayTokenEntity {
    try await repository.getApplePayToken(sessionId: sessionId, cardId: cardId)
  }
}
