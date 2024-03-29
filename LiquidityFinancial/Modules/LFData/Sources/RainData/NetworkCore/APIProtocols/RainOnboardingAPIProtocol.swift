import Foundation

// sourcery: AutoMockable
public protocol RainOnboardingAPIProtocol {
  func getOnboardingMissingSteps() async throws -> APIRainOnboardingMissingSteps
}
