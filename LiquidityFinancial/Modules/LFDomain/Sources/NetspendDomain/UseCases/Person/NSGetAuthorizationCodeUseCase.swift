import Foundation

public class NSGetAuthorizationCodeUseCase: NSGetAuthorizationCodeUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionId: String) async throws -> AuthorizationCodeEntity {
    try await repository.getAuthorizationCode(sessionId: sessionId)
  }
}
