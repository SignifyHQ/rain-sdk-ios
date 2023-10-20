import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidAPIProtocol where R == SolidRoute {
  
  public func createPlaidToken(accountId: String) async throws -> APICreatePlaidTokenResponse {
    return try await request(
      SolidRoute.createPlaidToken(accountId: accountId),
      target: APICreatePlaidTokenResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func plaidLink(accountId: String, token: String, plaidAccountId: String) async throws -> SolidContact {
    return try await request(
      SolidRoute.plaidLink(accountId: accountId, token: token, plaidAccountId: plaidAccountId),
      target: SolidContact.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
