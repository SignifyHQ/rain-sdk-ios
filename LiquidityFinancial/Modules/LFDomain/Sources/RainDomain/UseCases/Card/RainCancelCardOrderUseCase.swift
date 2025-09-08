import Foundation

public class RainCancelCardOrderUseCase: RainCancelCardOrderUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String) async throws -> RainCardEntity {
    try await repository.cancelOrder(cardID: cardID)
  }
}
