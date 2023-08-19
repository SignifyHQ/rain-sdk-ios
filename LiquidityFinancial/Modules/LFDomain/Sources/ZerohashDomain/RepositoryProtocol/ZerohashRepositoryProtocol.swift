import Foundation
import AccountDomain

public protocol ZerohashRepositoryProtocol {
  func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity
}
