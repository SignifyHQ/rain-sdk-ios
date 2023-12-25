import Foundation

public class GetSellQuoteUseCase: GetSellQuoteUseCaseProtocol {

  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, amount: String?, quantity: String?) async throws -> GetSellQuoteEntity {
    return try await repository.getSellQuote(accountId: accountId, amount: amount, quantity: quantity)
  }
}
