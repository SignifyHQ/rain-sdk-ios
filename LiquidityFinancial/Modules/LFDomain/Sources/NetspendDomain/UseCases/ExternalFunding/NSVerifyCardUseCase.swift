import Foundation
  
public class NSVerifyCardUseCase: NSVerifyCardUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    sessionId: String,
    request: VerifyExternalCardParametersEntity
  ) async throws -> VerifyExternalCardResponseEntity {
    try await self.repository.verifyCard(sessionId: sessionId, request: request)
  }
}
