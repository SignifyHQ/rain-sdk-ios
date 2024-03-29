import Foundation
import RainDomain

public class RainOnboardingRepository: RainOnboardingRepositoryProtocol {
  private let onboardingAPI: RainOnboardingAPIProtocol
  
  public init(onboardingAPI: RainOnboardingAPIProtocol) {
    self.onboardingAPI = onboardingAPI
  }
  
  public func getOnboardingMissingSteps() async throws -> RainOnboardingMissingStepsEntity {
    try await self.onboardingAPI.getOnboardingMissingSteps()
  }
}
