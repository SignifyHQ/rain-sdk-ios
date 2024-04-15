import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: RainAPIProtocol where R == RainOnboardingRoute {
  public func getOnboardingMissingSteps() async throws -> APIRainOnboardingMissingSteps {
    let result = try await request(
      RainOnboardingRoute.getOnboardingMissingSteps,
      target: [String].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    
    return APIRainOnboardingMissingSteps(processSteps: result)
  }
  
  public func createRainAccount(parameters: APIRainPersonParameters) async throws -> APIRainPerson {
    try await request(
      RainOnboardingRoute.createAccount(parameters: parameters),
      target: APIRainPerson.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
