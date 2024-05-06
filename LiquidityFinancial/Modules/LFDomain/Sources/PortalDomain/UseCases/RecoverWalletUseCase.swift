import Foundation
import PortalSwift

public final class RecoverWalletUseCase: RecoverWalletUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(backupMethod: PortalSwift.BackupMethods, password: String?) async throws {
    try await repository.recoverWallet(backupMethod: backupMethod, password: password)
  }
}
