import Foundation

public final class RefreshPortalAssetsUseCase: RefreshPortalAssetsUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  private let storage: PortalStorageProtocol
  
  public init(
    repository: PortalRepositoryProtocol,
    storage: PortalStorageProtocol
  ) {
    self.repository = repository
    self.storage = storage
  }
  
  public func execute() async throws {
    try await repository.refreshBalances()
  }
}
