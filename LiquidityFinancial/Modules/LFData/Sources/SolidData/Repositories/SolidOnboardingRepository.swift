import Foundation
import SolidDomain

public class SolidOnboardingRepository: SolidOnboardingRepositoryProtocol {
  private let onboardingAPI: SolidOnboardingAPIProtocol
  
  public init(onboardingAPI: SolidOnboardingAPIProtocol) {
    self.onboardingAPI = onboardingAPI
  }
  
  public func getOnboardingStep() async throws -> SolidOnboardingStepEntity {
    try await self.onboardingAPI.getOnboardingStep()
  }
  
  public func createPerson(parameters: SolidPersonParametersEntity) async throws -> Bool {
    guard let parameters = parameters as? APISolidPersonParameters else { return false }
    return try await self.onboardingAPI.createPerson(parameters: parameters)
  }
}

extension APISolidOnboardingStep: SolidOnboardingStepEntity {}
