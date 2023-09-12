import Foundation
import AccountDomain

public protocol ZerohashRepositoryProtocol {
  func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity
  func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse
  func execute(accountId: String, quoteId: String) async throws -> TransactionEntity
}
