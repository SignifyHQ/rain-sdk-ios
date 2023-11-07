import Foundation
  
public class ZerohashGetAccountsUseCase: ZerohashGetAccountsUseCaseProtocol {
  
  private let repository: ZerohashAccountRepositoryProtocol
  
  public init(repository: ZerohashAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [ZerohashAccountEntity] {
    try await self.repository.getAccounts()
  }
}
