import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidExternalFundingAPIProtocol where R == SolidExternalFundingRoute {
  
  public func createDebitCardToken(accountID: String) async throws -> APISolidDebitCardToken {
    try await request(
      SolidExternalFundingRoute.createDebitCardToken(accountID: accountID),
      target: APISolidDebitCardToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createPlaidToken(accountId: String) async throws -> APICreatePlaidTokenResponse {
    return try await request(
      SolidExternalFundingRoute.createPlaidToken(accountId: accountId),
      target: APICreatePlaidTokenResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func plaidLink(accountId: String, token: String, plaidAccountId: String) async throws -> SolidContact {
    return try await request(
      SolidExternalFundingRoute.plaidLink(accountId: accountId, token: token, plaidAccountId: plaidAccountId),
      target: SolidContact.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
