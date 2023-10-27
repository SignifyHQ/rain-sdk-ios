import Foundation
  
public class NSGetLinkedAccountUseCase: NSGetLinkedAccountUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(sessionId: String) async throws -> any LinkedSourcesEntity {
    try await repository.getLinkedAccount(sessionId: sessionId)
  }
}
