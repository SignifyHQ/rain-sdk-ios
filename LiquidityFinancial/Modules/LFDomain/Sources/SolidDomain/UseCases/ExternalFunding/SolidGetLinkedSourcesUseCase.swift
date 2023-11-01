import Foundation
  
public class SolidGetLinkedSourcesUseCase: SolidGetLinkedSourcesUseCaseProtocol {
  
  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountID: String) async throws -> [SolidContactEntity] {
    try await self.repository.getLinkedSources(accountID: accountID)
  }
}
