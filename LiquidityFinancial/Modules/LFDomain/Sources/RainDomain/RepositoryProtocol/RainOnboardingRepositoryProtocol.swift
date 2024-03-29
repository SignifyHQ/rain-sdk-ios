import Foundation

// sourcery: AutoMockable
public protocol RainOnboardingRepositoryProtocol {
  func getOnboardingMissingSteps() async throws -> RainOnboardingMissingStepsEntity
}
