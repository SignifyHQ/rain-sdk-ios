import Foundation

// sourcery: AutoMockable
public protocol RainAPIProtocol {
  func getOnboardingMissingSteps() async throws -> APIRainOnboardingMissingSteps
  func createRainAccount(parameters: APIRainPersonParameters) async throws -> APIRainPerson
}
