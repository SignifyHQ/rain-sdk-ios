import Foundation
import BankDomain

public class NSOnboardingRepository: NSOnboardingRepositoryProtocol {
  private let onboardingAPI: NSOnboardingAPIProtocol
  
  public init(onboardingAPI: NSOnboardingAPIProtocol) {
    self.onboardingAPI = onboardingAPI
  }
  
  public func getOnboardingStep(sessionID: String) async throws -> NSOnboardingStepEntity {
    try await onboardingAPI.getOnboardingStep(sessionID: sessionID)
  }
}

extension APINSOnboardingStep: NSOnboardingStepEntity {}
