import Foundation
import PortalSwift

public final class BackupWalletUseCase: BackupWalletUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    backupMethod: BackupMethods,
    password: String?
  ) async throws {
    try await repository.backupWallet(backupMethod: backupMethod, password: password)
  }
}
