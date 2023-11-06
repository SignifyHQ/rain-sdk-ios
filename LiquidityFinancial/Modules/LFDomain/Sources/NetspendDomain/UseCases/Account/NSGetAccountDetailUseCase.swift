import Foundation
  
public class NSGetAccountDetailUseCase: NSGetAccountDetailUseCaseProtocol {
  
  private let repository: NSAccountRepositoryProtocol
  
  public init(repository: NSAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(id: String) async throws -> NSAccountEntity {
    try await self.repository.getAccountDetail(id: id)
  }
}
