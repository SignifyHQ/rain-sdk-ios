import Foundation

public protocol GetBuyQuoteUseCaseProtocol {
  func execute(accountId: String, amount: String?, quantity: String?) async throws -> GetBuyQuoteEntity
}
