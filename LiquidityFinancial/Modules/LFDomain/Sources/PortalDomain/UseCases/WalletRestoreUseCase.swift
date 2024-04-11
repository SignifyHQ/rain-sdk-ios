import Foundation

public final class WalletRestoreUseCase: WalletRestoreUseCaseProtocol {
  
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(method: String) async throws -> WalletRestoreEntitiy {
    try await repository.restoreWallet(method: method)
  }
}
