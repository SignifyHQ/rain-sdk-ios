import Foundation
import FeatureFlagDomain
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: FeatureFlagAPIProtocol where R == FeatureFlagRoute {
  
  public func list() async throws -> APIListFeatureFlagResponse {
    return try await request(
      FeatureFlagRoute.list,
      target: APIListFeatureFlagResponse.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
