import Foundation
  
public class SolidActiveCardUseCase: SolidActiveCardUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, parameters: SolidActiveCardParametersEntity) async throws -> SolidCardEntity {
    try await self.repository.activeCard(cardID: cardID, parameters: parameters)
  }
}
