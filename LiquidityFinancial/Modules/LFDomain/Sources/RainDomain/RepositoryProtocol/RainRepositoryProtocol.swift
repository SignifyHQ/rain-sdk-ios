import Foundation

// sourcery: AutoMockable
public protocol RainRepositoryProtocol {
  func getOnboardingMissingSteps() async throws -> RainOnboardingMissingStepsEntity
  func createRainAccount(parameters: RainPersonParametersEntity) async throws -> RainPersonEntity
}
