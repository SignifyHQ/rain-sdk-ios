import Foundation

public protocol NSOnboardingAPIProtocol {
  func getOnboardingStep(sessionID: String) async throws -> APINSOnboardingStep
}
