import Foundation
import NetSpendDomain
import DataUtilities
import LFNetwork
import LFUtilities

extension LFNetwork: NSExternalFundingAPIProtocol where R == NSExternalFundingRoute {
  public func set(request: ExternalCardParameters, sessionID: String) async throws -> APIExternalCard {
    return try await self.request(
      NSExternalFundingRoute.set(request, sessionID),
      target: APIExternalCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getPinWheelToken(sessionID: String) async throws -> APIPinWheelToken {
    try await request(
      NSExternalFundingRoute.pinWheelToken(sessionID),
      target: APIPinWheelToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getACHInfo(sessionID: String) async throws -> APIACHInfo {
    try await request(
      NSExternalFundingRoute.getACHInfo(sessionID),
      target: APIACHInfo.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getLinkedSources(sessionID: String) async throws -> APILinkedSourcesResponse {
    try await request(
      NSExternalFundingRoute.getLinkedSource(sessionId: sessionID),
      target: APILinkedSourcesResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func deleteLinkedSource(sessionId: String, sourceId: String) async throws -> APIUnlinkBankResponse {
    let result = try await request(NSExternalFundingRoute.deleteLinkedSource(sessionId: sessionId, sourceId: sourceId))
    let statusCode = result.httpResponse?.statusCode
    return APIUnlinkBankResponse(success: statusCode == 200 || statusCode == 204)
  }
  
  public func newTransaction(parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String) async throws -> APIExternalTransactionResponse {
    return try await self.request(
      NSExternalFundingRoute.newTransaction(parameters, type, sessionId),
      target: APIExternalTransactionResponse.self,
      decoder: .apiDecoder
    )
  }
}
