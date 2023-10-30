import Foundation

public protocol NSGetOnboardingStepUseCaseProtocol {
  func execute(sessionID: String) async throws -> NSOnboardingStepEntity
}
