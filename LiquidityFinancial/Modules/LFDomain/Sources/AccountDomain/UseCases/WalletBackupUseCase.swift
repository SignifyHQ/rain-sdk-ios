import Foundation

public final class WalletBackupUseCase: WalletBackupUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cipher: String, method: String) async throws {
    try await repository.backupWallet(cipher: cipher, method: method)
  }
}
