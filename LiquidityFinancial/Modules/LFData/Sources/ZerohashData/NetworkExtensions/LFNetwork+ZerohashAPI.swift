import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities
import AccountData

extension LFCoreNetwork: ZerohashAPIProtocol where R == ZerohashRoute {
  
  public func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> APITransaction {
    return try await request(
      ZerohashRoute.sendCrypto(accountId: accountId, destinationAddress: destinationAddress, amount: amount),
      target: APITransaction.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
