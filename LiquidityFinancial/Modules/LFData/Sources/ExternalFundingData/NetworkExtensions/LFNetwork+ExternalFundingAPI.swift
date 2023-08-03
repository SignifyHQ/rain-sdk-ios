import Foundation
import ExternalFundingDomain
import DataUtilities
import LFNetwork
import LFUtilities

extension LFNetwork: ExternalFundingAPIProtocol where R == ExternalFundingRoute {
  public func set(request: ExternalCardParameters, sessionID: String) async throws -> APIExternalCard {
    return try await self.request(
      ExternalFundingRoute.set(request, sessionID),
      target: APIExternalCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getPinWheelToken(sessionID: String) async throws -> APIPinWheelToken {
    try await request(
      ExternalFundingRoute.pinWheelToken(sessionID),
      target: APIPinWheelToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getACHInfo(sessionID: String) async throws -> APIACHInfo {
    try await request(
      ExternalFundingRoute.getACHInfo(sessionID),
      target: APIACHInfo.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
