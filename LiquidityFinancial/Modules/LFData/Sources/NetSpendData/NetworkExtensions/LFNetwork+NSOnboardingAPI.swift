import Foundation
import NetSpendDomain
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: NSOnboardingAPIProtocol where R == NSOnboardingRoute {
  public func getOnboardingStep(sessionID: String) async throws -> APINSOnboardingStep {
    let result = try await request(NSOnboardingRoute.getOnboardingStep(sessionID: sessionID), target: [String].self, failure: LFErrorObject.self, decoder: .apiDecoder)
    return APINSOnboardingStep(processSteps: result)
  }
}
