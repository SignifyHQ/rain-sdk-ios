import Foundation

public protocol NSOnboardingUseCaseProtocol {
  func getOnboardingStep(sessionID: String) async throws -> NSOnboardingStepEntity
}
