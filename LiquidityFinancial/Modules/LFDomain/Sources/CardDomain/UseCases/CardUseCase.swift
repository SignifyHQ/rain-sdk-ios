import Foundation

public class CardUseCase: CardUseCaseProtocol {
  
  private let repository: CardRepositoryProtocol
  
  public init(repository: CardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func getListCard() async throws -> [CardEntity] {
    return try await repository.getListCard()
  }
  
}
