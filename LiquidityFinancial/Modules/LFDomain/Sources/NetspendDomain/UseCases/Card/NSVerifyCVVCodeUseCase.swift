import Foundation

public class NSVerifyCVVCodeUseCase: NSVerifyCVVCodeUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    requestParam: VerifyCVVCodeParametersEntity,
    cardID: String,
    sessionID: String
  ) async throws -> VerifyCVVCodeEntity {
    try await repository.verifyCVVCode(
      verifyRequest: requestParam,
      cardID: cardID,
      sessionID: sessionID
    )
  }
}
