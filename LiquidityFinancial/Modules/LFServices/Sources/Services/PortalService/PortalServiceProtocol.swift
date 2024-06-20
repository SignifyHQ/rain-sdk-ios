import Foundation
import Combine
import PortalSwift

// MARK: - PortalServiceProtocol

public protocol PortalServiceProtocol {
  func registerPortal(sessionToken: String) async throws
  func createWallet() async throws -> String
  func send(to address: String, contractAddress: String?, amount: Double) async throws -> String
  func withdrawAsset(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> String
  func estimateTransferFee(to address: String, contractAddress: String?, amount: Double) async throws -> Double
  func estimateWithdrawalFee(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> Double
  func backup(backupMethod: BackupMethods, password: String?) async throws -> (String, () async throws -> Void)
  func recover(backupMethod: BackupMethods, password: String?, cipherText: String) async throws
  func refreshBalances() async throws -> (walletAddress: String?, balances: [String: Double])
  func getSwapQuote(sellToken: String, buyToken: String, buyAmount: Double) async throws -> Quote
  func executeSwap(quote: Quote) async throws -> String
  func getWalletAddress() async -> String?
  func isWalletOnDevice() async -> Bool
  var walletAddress: String? { get }
}
