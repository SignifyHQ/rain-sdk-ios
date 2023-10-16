import Foundation

public protocol OnboardingUseCaseProtocol {
  func execute(sessionId: String) async throws -> OnboardingStateEnity
}
