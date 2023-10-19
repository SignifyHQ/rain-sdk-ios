import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidOnboardingAPIProtocol where R == SolidOnboardingRoute {
  public func createPerson(parameters: APISolidPersonParameters) async throws -> Bool {
    let result = try await request(
      SolidOnboardingRoute.createPerson(parameters: parameters)
    )
    let statusCode = result.httpResponse?.statusCode ?? 500
    return statusCode.isSuccess
  }
  
  public func getOnboardingStep() async throws -> APISolidOnboardingStep {
    let result = try await request(SolidOnboardingRoute.getOnboardingStep, target: [String].self, failure: LFErrorObject.self, decoder: .apiDecoder)
    return APISolidOnboardingStep(processSteps: result)
  }
}
