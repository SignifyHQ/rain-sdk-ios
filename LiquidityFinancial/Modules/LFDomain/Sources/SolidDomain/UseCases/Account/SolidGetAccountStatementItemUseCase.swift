import Foundation

public class SolidGetAccountStatementItemUseCase: SolidGetAccountStatementItemUseCaseProtocol {
  
  private let repository: SolidAccountRepositoryProtocol
  
  public init(repository: SolidAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(liquidityAccountId: String, fileName: String, year: String, month: String) async throws -> SolidAccountStatementItemEntity {
    try await self.repository.getStatement(liquidityAccountId: liquidityAccountId, fileName: fileName, year: year, month: month)
  }
}
