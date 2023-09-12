import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities
import AccountData
import ZerohashDomain

extension LFCoreNetwork: ZerohashAPIProtocol where R == ZerohashRoute {
  
  public func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> APITransaction {
    return try await request(
      ZerohashRoute.sendCrypto(accountId: accountId, destinationAddress: destinationAddress, amount: amount),
      target: APITransaction.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func lockedNetworkFee(accountId: String, destinationAddress: String, amount: Double, maxAmount: Bool) async throws -> APILockedNetworkFeeResponse {
    return try await request(
      ZerohashRoute.lockedNetworkFee(
        accountId: accountId,
        destinationAddress: destinationAddress,
        amount: amount,
        maxAmount: maxAmount
      ),
      target: APILockedNetworkFeeResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func execute(accountId: String, quoteId: String) async throws -> APITransaction {
    return try await request(
      ZerohashRoute.executeQuote(accountId: accountId, quoteId: quoteId),
      target: APITransaction.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
