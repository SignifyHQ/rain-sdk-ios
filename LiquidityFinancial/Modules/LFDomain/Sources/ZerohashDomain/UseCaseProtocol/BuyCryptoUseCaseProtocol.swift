import Foundation

public protocol BuyCryptoUseCaseProtocol {
  func execute(accountId: String, quoteId: String) async throws -> BuyCryptoEntity
}
