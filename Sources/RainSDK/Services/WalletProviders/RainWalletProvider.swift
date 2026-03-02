import Foundation

/// Abstraction for a wallet/signer used for address, balance, transfers, and signing.
/// Implementations: Portal (via `PortalWalletProviderAdapter`), Web3Auth, or other providers.
public protocol RainWalletProvider: Sendable {
  /// Returns the wallet address for the given chain.
  func address(
  ) async throws -> String

  /// Sends a transaction; returns the transaction hash.
  func sendTransaction(
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> String
}
