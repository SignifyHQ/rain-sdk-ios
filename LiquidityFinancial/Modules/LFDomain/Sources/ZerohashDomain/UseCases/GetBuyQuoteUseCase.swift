import Foundation

public class GetBuyQuoteUseCase: GetBuyQuoteUseCaseProtocol {

  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, amount: String?, quantity: String?) async throws -> GetBuyQuoteEntity {
    return try await repository.getBuyQuote(accountId: accountId, amount: amount, quantity: quantity)
  }
}
