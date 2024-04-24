import Foundation

public final class RefreshPortalAssetsUseCase: RefreshPortalAssetsUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws {
    try await repository.refreshAssets()
  }
}
