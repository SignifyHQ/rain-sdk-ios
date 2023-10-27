import Foundation
  
public class NSDeleteLinkedAccountUseCase: NSDeleteLinkedAccountUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(sessionId: String, sourceId: String, sourceType: String) async throws -> UnlinkBankEntity {
    try await repository.deleteLinkedAccount(sessionId: sessionId, sourceId: sourceId, sourceType: sourceType)
  }
}
