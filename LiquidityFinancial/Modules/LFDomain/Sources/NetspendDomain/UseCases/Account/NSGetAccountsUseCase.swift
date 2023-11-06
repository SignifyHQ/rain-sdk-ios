import Foundation
  
public class NSGetAccountsUseCase: NSGetAccountsUseCaseProtocol {
  
  private let repository: NSAccountRepositoryProtocol
  
  public init(repository: NSAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [NSAccountEntity] {
    try await self.repository.getAccounts()
  }
}
