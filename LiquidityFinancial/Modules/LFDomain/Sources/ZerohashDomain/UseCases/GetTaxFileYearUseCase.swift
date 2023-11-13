import Foundation

public class GetTaxFileYearUseCase: GetTaxFileYearUseCaseProtocol {
  
  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, year: String, fileName: String) async throws -> URL {
    try await repository.getTaxFileYear(accountId: accountId, year: year, fileName: fileName)
  }
  
}
