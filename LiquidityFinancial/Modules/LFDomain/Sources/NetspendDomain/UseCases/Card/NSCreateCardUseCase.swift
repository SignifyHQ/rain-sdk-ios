import Foundation

public class NSCreateCardUseCase: NSCreateCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionID: String) async throws -> NSCardEntity {
    try await repository.createCard(sessionID: sessionID)
  }
}
