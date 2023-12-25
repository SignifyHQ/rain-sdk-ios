import Foundation

public protocol SellCryptoUseCaseProtocol {
  func execute(accountId: String, quoteId: String) async throws -> SellCryptoEntity
}
