import Foundation
import ZerohashDomain
import AccountDomain
import LFUtilities

public class ZerohashRepository: ZerohashRepositoryProtocol {
  private let zerohashAPI: ZerohashAPIProtocol
  
  public init(zerohashAPI: ZerohashAPIProtocol) {
    self.zerohashAPI = zerohashAPI
  }
  
  public func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity {
    return try await self.zerohashAPI.sendCrypto(accountId: accountId, destinationAddress: destinationAddress, amount: amount)
  }
  
  public func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse {
    return try await self.zerohashAPI.lockedNetworkFee(
      accountId: accountId,
      destinationAddress: destinationAddress,
      amount: amount,
      maxAmount: maxAmount
    )
  }
  
  public func execute(accountId: String, quoteId: String) async throws -> TransactionEntity {
    return try await self.zerohashAPI.execute(
      accountId: accountId, quoteId: quoteId
    )
  }
}
