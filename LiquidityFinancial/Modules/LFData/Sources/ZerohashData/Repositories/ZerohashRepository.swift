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
}
