import Foundation

public class RainGetCardsUseCase: RainGetCardsUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [RainCardEntity] {
    try await repository.getCards()
  }
}
