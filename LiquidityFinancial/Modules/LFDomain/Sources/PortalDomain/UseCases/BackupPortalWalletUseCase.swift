import Foundation
import PortalSwift

public final class BackupPortalWalletUseCase: BackupPortalWalletUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    backupMethod: BackupMethods,
    backupConfigs: BackupConfigs?
  ) async throws -> String {
    try await repository.backupPortalWallet(backupMethod: backupMethod, backupConfigs: backupConfigs)
  }
}
