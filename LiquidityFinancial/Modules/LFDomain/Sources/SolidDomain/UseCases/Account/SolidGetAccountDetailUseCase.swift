import Foundation
  
public class SolidGetAccountDetailUseCase: SolidGetAccountDetailUseCaseProtocol {
  
  private let repository: SolidAccountRepositoryProtocol
  
  public init(repository: SolidAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(id: String) async throws -> SolidAccountEntity {
    try await self.repository.getAccountDetail(id: id)
  }
}
