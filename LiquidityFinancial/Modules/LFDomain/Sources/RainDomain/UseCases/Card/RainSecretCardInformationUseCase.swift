import Foundation

public class RainSecretCardInformationUseCase: RainSecretCardInformationUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionID: String, cardID: String) async throws -> RainSecretCardInformationEntity {
    try await repository.getSecretCardInformation(sessionID: sessionID, cardID: cardID)
  }
}
