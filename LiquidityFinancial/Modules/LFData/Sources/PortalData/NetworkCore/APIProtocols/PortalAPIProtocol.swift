import Foundation

// sourcery: AutoMockable
public protocol PortalAPIProtocol {
  func backupWallet(cipher: String, method: String) async throws
  func restoreWallet(method: String) async throws -> APIWalletRestore
  func refreshPortalSessionToken() async throws -> APIPortalSessionToken
  func verifyAndUpdatePortalWalletAddress() async throws
}
