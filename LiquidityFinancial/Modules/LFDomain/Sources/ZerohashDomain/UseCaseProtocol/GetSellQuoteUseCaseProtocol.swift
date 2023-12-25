import Foundation

public protocol GetSellQuoteUseCaseProtocol {
  func execute(accountId: String, amount: String?, quantity: String?) async throws -> GetSellQuoteEntity
}
