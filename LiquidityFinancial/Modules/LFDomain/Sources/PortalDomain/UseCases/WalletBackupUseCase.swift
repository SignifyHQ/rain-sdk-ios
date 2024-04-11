import Foundation

public final class WalletBackupUseCase: WalletBackupUseCaseProtocol {
  
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cipher: String, method: String) async throws {
    try await repository.backupWallet(cipher: cipher, method: method)
  }
}
