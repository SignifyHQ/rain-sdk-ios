import Foundation
  
public class NSGetACHInfoUseCase: NSGetACHInfoUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(sessionID: String) async throws -> ACHInfoEntity {
    try await repository.getACHInfo(sessionID: sessionID)
  }
}
