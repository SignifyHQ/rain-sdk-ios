import Foundation
import Combine
import PortalSwift

// MARK: - PortalServiceProtocol

public protocol PortalServiceProtocol {
  func registerPortal(sessionToken: String) async throws
  func createWallet() async throws -> String
  func send(to address: String,amount: Double) async throws
  func estimateFee(to address: String, amount: Double) async throws -> Double
  func backup(backupMethod: BackupMethods, backupConfigs: BackupConfigs?) async throws -> String
  func confirmWalletBackupStorage(backupMethod: BackupMethods, stored: Bool) async throws
  func recover(backupMethod: BackupMethods, backupConfigs: BackupConfigs?, cipherText: String) async throws
  func getAssets() async throws -> [PortalAsset]
  func checkWalletAddressExists() -> Bool
  var walletAddress: String? { get }
}
