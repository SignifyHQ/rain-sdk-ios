import Foundation

// sourcery: AutoMockable
public protocol SolidOnboardingAPIProtocol {
  func getOnboardingStep() async throws -> APISolidOnboardingStep
  func createPerson(parameters: APISolidPersonParameters) async throws -> Bool
}
