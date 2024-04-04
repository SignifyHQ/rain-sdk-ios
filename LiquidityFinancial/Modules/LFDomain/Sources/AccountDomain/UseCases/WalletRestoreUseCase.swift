import Foundation

public final class WalletRestoreUseCase: WalletRestoreUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(method: String) async throws -> WalletRestoreEntitiy {
    try await repository.restoreWallet(method: method)
  }
}
