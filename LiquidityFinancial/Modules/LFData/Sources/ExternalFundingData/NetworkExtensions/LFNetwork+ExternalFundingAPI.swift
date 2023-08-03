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
}
