import Foundation

public class RainActivatePhysicalCardUseCase: RainActivatePhysicalCardUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, parameters: RainActivateCardParametersEntity) async throws {
    try await repository.activatePhysicalCard(cardID: cardID, parameters: parameters)
  }
}
