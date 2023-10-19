import Foundation

public protocol SolidOnboardingUseCaseProtocol {
  func execute() async throws -> SolidOnboardingStepEntity
}
