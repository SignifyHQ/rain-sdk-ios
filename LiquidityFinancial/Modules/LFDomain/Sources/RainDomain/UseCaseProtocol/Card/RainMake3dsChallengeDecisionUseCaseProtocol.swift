import Foundation

public protocol RainMake3dsChallengeDecisionUseCaseProtocol {
  func execute(approvalId: String, decision: String) async throws
}
