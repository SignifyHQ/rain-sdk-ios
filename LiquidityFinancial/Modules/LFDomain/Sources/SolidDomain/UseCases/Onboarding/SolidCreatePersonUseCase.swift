import Foundation
  
public class SolidCreatePersonUseCase: SolidCreatePersonUseCaseProtocol {
  
  private let repository: SolidOnboardingRepositoryProtocol
  
  public init(repository: SolidOnboardingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: SolidPersonParametersEntity) async throws -> Bool {
    try await self.repository.createPerson(parameters: parameters)
  }
}
