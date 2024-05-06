import Foundation
import PortalSwift

public protocol BackupWalletUseCaseProtocol {
  func execute(
    backupMethod: BackupMethods,
    password: String?
  ) async throws
}
