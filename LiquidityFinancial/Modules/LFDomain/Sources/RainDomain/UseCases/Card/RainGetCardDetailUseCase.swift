import Foundation

public class RainGetCardDetailUseCase: RainGetCardDetailUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> RainCardDetailEntity {
    try await repository.getCardDetail(cardID: cardID)
  }
}
