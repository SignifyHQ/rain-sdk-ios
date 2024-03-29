import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: RainOnboardingAPIProtocol where R == RainOnboardingRoute {
  public func getOnboardingMissingSteps() async throws -> APIRainOnboardingMissingSteps {
    let result = try await request(
      RainOnboardingRoute.getOnboardingMissingSteps,
      target: [String].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    
    return APIRainOnboardingMissingSteps(processSteps: result)
  }
}
