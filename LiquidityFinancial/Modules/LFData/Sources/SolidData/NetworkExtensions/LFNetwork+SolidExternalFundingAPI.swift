import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidExternalFundingAPIProtocol where R == SolidExternalFundingRoute {
  
  public func getLinkedSources(accountId: String) async throws -> [APISolidContact] {
    try await request(
      SolidExternalFundingRoute.getLinkedSources(accountId: accountId),
      target: [APISolidContact].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
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
  
  public func plaidLink(accountId: String, token: String, plaidAccountId: String) async throws -> APISolidContact {
    return try await request(
      SolidExternalFundingRoute.plaidLink(accountId: accountId, token: token, plaidAccountId: plaidAccountId),
      target: APISolidContact.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func unlinkContact(id: String) async throws -> APISolidUnlinkContactResponse {
    let result = try await request(SolidExternalFundingRoute.unlinkContact(id: id))
    let statusCode = result.httpResponse?.statusCode
    return APISolidUnlinkContactResponse(success: statusCode?.isSuccess ?? false)
  }
  
  public func getWireTransfer(accountId: String) async throws -> APISolidWireTransferResponse {
    return try await request(
      SolidExternalFundingRoute.getWireTransfer(accountId: accountId),
      target: APISolidWireTransferResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
