import Foundation
import PortalSwift

public protocol BackupPortalWalletUseCaseProtocol {
  func execute(
    backupMethod: BackupMethods,
    backupConfigs: BackupConfigs?
  ) async throws -> String
}
