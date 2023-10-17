import Foundation

public protocol OnboardingStepUseCaseProtocol {
  func execute() async throws -> ZHOnboardingStepEntity
}
