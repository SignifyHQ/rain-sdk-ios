import Foundation
import PortalSwift

public final class RecoverPortalWalletUseCase: RecoverPortalWalletUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    backupMethod: PortalSwift.BackupMethods,
    backupConfigs: PortalSwift.BackupConfigs?,
    cipherText: String
  ) async throws {
    try await repository.recoverPortalWallet(
      backupMethod: backupMethod,
      backupConfigs: backupConfigs,
      cipherText: cipherText
    )
  }
}
