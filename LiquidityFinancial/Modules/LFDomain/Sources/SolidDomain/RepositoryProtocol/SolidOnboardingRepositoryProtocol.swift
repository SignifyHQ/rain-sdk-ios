import Foundation

// sourcery: AutoMockable
public protocol SolidOnboardingRepositoryProtocol {
  func getOnboardingStep() async throws -> SolidOnboardingStepEntity
  func createPerson(parameters: SolidPersonParametersEntity) async throws -> Bool
}
