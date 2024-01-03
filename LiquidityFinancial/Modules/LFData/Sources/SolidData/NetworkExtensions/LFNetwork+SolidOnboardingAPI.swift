import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidOnboardingAPIProtocol where R == SolidOnboardingRoute {
  public func createPerson(parameters: APISolidPersonParameters) async throws -> Bool {
    let result = try await request(
      SolidOnboardingRoute.createPerson(parameters: parameters)
    )
    let status = (result.httpResponse?.statusCode ?? 500).isSuccess
    if !status, let data = result.data {
      try LFCoreNetwork.processingStringError(data)
    }
    return status
  }
  
  public func getOnboardingStep() async throws -> APISolidOnboardingStep {
    let result = try await request(SolidOnboardingRoute.getOnboardingStep, target: [String].self, failure: LFErrorObject.self, decoder: .apiDecoder)
    return APISolidOnboardingStep(processSteps: result)
  }
}
