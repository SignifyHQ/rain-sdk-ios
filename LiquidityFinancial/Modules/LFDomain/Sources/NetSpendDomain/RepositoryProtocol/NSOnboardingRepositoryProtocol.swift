import Foundation

public protocol NSOnboardingRepositoryProtocol {
  func getOnboardingStep(sessionID: String) async throws -> NSOnboardingStepEntity
}
