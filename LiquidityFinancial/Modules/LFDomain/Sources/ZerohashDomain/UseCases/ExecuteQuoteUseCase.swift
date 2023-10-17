import Foundation
import AccountDomain

public class ExecuteQuoteUseCase: ExecuteQuoteUseCaseProtocol {
  
  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, quoteId: String) async throws -> TransactionEntity {
    return try await repository.execute(accountId: accountId, quoteId: quoteId)
  }
  
}
