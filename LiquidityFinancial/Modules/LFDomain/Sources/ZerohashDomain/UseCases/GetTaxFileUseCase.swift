import Foundation

public class GetTaxFileUseCase: GetTaxFileUseCaseProtocol {
  
  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String) async throws -> [any TaxFileEntity] {
    return try await repository.getTaxFile(accountId: accountId)
  }
  
}
