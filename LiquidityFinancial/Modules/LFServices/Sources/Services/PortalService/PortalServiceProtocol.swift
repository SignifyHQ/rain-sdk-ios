import Foundation
import Combine
import PortalSwift

// MARK: - PortalServiceProtocol

public protocol PortalServiceProtocol {
  func registerPortal(sessionToken: String) async throws
  func createWallet() async throws -> String
  func send(to address: String, contractAddress: String?, amount: Double) async throws
  func estimateFee(to address: String, contractAddress: String?, amount: Double) async throws -> Double
  func backup(backupMethod: BackupMethods, password: String?) async throws -> (String, () async throws -> Void)
  func recover(backupMethod: BackupMethods, password: String?, cipherText: String) async throws
  func refreshBalances() async throws -> (walletAddress: String?, balances: [String: Double])
  func getWalletAddress() async -> String?
  var walletAddress: String? { get }
}
