import Foundation

public final class RefreshPortalBalancesUseCase: RefreshPortalBalancesUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws {
    try await repository.refreshBalances()
  }
}
