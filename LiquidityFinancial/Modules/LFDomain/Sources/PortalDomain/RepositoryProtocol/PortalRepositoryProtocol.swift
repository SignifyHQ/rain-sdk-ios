import Foundation
import PortalSwift
import Services

// sourcery: AutoMockable
public protocol PortalRepositoryProtocol {
  func verifyAndUpdatePortalWalletAddress() async throws
  func registerPortal(portalToken: String) async throws
  func createPortalWallet() async throws -> String
  func send(to address: String, contractAddress: String?, amount: Double) async throws -> String
  func withdrawAsset(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> String
  func estimateFee(to address: String, contractAddress: String?, amount: Double) async throws -> Double
  func backupWallet(backupMethod: BackupMethods, password: String?) async throws
  func recoverWallet(backupMethod: BackupMethods,password: String?) async throws
  func refreshBalances() async throws
  func getPortalBackupMethods() async throws -> PortalBackupMethodsEntity
}
