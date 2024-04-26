import Foundation
import PortalSwift

public protocol RecoverPortalWalletUseCaseProtocol {
  func execute(
    backupMethod: BackupMethods,
    backupConfigs: BackupConfigs?,
    cipherText: String
  ) async throws
}
