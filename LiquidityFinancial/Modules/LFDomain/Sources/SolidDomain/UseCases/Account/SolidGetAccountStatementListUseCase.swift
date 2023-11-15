import Foundation

public class SolidGetAccountStatementListUseCase: SolidGetAccountStatementListUseCaseProtocol {
  
  private let repository: SolidAccountRepositoryProtocol
  
  public init(repository: SolidAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(liquidityAccountId: String) async throws -> [SolidAccountStatementListEntity] {
    return try await repository.getAllStatement(liquidityAccountId: liquidityAccountId)
  }
}
