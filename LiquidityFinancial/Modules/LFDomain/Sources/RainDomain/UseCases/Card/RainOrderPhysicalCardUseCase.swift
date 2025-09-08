import Foundation

public class RainOrderPhysicalCardUseCase: RainOrderPhysicalCardUseCaseProtocol {
  
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: RainOrderCardParametersEntity, shouldBeApproved: Bool) async throws -> RainCardEntity {
    try await repository.orderPhysicalCard(parameters: parameters, shouldBeApproved: shouldBeApproved)
  }
}
