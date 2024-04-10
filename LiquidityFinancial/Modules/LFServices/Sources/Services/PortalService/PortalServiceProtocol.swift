import Foundation
import Combine
import PortalSwift

// MARK: - PortalServiceProtocol

public protocol PortalServiceProtocol {
  func registerPortal(sessionToken: String, alchemyAPIKey: String) async throws
  func createWallet() async throws -> String
  func backup(
    backupMethod: BackupMethods,
    backupConfigs: BackupConfigs?
  ) async throws -> String
  func recover(
    backupMethod: BackupMethods,
    cipherText: String
  ) async throws
  func checkWalletAddressExists() -> Bool
}
