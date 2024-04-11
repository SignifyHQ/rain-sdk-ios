import Foundation

public final class RegisterPortalUseCase: RegisterPortalUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(portalToken: String) async throws {
    try await repository.registerPortal(portalToken: portalToken)
  }
}
