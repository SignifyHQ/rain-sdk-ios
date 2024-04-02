import Foundation

public final class RefreshPortalSessionTokenUseCase: RefreshPortalSessionTokenUseCaseProtocol {
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> PortalSessionTokenEntity {
    try await repository.refreshPortalSessionToken()
  }
}
