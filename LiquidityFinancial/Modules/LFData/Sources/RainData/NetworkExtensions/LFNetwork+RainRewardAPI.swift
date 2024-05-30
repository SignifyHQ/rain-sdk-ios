import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: RainRewardAPIProtocol where R == RainRewardRoute {
  public func getRewardBalance() async throws -> APIRainRewardBalance {
    try await request(
      RainRewardRoute.getRewardBalance,
      target: APIRainRewardBalance.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
