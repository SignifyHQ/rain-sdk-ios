import Foundation
import PortalSwift

// sourcery: AutoMockable
public protocol PortalRepositoryProtocol {
  func backupWallet(cipher: String, method: String) async throws
  func restoreWallet(method: String) async throws -> WalletRestoreEntitiy
  func refreshPortalSessionToken() async throws -> PortalSessionTokenEntity
  func verifyAndUpdatePortalWalletAddress() async throws
  func registerPortal(portalToken: String) async throws
  func createPortalWallet() async throws -> String
  func backupPortalWallet(
    backupMethod: BackupMethods,
    backupConfigs: BackupConfigs?
  ) async throws -> String
  func recoverPortalWallet(
    backupMethod: BackupMethods,
    backupConfigs: BackupConfigs?,
    cipherText: String
  ) async throws
  func refreshAssets() async throws
}
