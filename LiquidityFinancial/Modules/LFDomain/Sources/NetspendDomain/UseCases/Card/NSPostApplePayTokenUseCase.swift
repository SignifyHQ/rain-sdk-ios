import Foundation

public class NSPostApplePayTokenUseCase: NSPostApplePayTokenUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    sessionId: String,
    cardId: String,
    bodyData: [String: Any]
  ) async throws -> PostApplePayTokenEntity {
    try await repository.postApplePayToken(sessionId: sessionId, cardId: cardId, bodyData: bodyData)
  }
}
