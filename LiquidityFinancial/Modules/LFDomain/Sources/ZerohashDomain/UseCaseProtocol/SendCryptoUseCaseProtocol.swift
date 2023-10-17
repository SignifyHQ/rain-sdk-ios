import Foundation
import AccountDomain

public protocol SendCryptoUseCaseProtocol {
  func execute(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity
}
