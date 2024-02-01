import Foundation
  
public class SolidGetListCardUseCase: SolidGetListCardUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(isContainClosedCard: Bool) async throws -> [SolidCardEntity] {
    try await self.repository.getListCard(isContainClosedCard: isContainClosedCard)
  }
}
