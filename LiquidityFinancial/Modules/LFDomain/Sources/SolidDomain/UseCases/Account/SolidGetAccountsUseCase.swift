import Foundation
  
public class SolidGetAccountsUseCase: SolidGetAccountsUseCaseProtocol {
  
  private let repository: SolidAccountRepositoryProtocol
  
  public init(repository: SolidAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [SolidAccountEntity] {
    try await self.repository.getAccounts()
  }
}
