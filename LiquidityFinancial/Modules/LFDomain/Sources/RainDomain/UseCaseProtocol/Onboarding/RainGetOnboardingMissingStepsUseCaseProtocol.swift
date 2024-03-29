import Foundation

public protocol RainGetOnboardingMissingStepsUseCaseProtocol {
  func execute() async throws -> RainOnboardingMissingStepsEntity
}
