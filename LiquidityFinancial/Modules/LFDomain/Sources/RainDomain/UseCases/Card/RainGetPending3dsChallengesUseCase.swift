import Foundation

public class RainGetPending3dsChallengesUseCase: RainGetPending3dsChallengesUseCaseProtocol {
  private let repository: RainCardRepositoryProtocol
  
  public init(repository: RainCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [Pending3dsChallengeEntity] {
    try await repository.getPending3dsChallenges()
  }
}
