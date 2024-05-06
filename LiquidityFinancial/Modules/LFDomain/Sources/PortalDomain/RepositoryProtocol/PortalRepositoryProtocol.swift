import Foundation
import PortalSwift

// sourcery: AutoMockable
public protocol PortalRepositoryProtocol {
  func refreshPortalSessionToken() async throws -> PortalSessionTokenEntity
  func verifyAndUpdatePortalWalletAddress() async throws
  func registerPortal(portalToken: String) async throws
  func createPortalWallet() async throws -> String
  func send(to address: String, contractAddress: String?, amount: Double) async throws
  func estimateFee(to address: String, contractAddress: String?, amount: Double) async throws -> Double
  func backupWallet(backupMethod: BackupMethods, password: String?) async throws
  func recoverWallet(backupMethod: BackupMethods,password: String?) async throws
  func refreshBalances() async throws
  func getPortalBackupMethods() async throws -> PortalBackupMethodsEntity
}
