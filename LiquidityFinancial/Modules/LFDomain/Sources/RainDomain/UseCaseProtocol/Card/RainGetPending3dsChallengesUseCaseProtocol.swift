import Foundation

public protocol RainGetPending3dsChallengesUseCaseProtocol {
 func execute() async throws -> [Pending3dsChallengeEntity]
}
