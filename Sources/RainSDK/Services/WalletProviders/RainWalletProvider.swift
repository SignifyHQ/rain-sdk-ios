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

  /// Fetches a single balance (native or a contract token) as a rich `Balance`.
  /// - Parameters:
  ///   - chainId: The target blockchain network identifier.
  ///   - token: `.native` or a `.contract(address:)`.
  /// - Returns: A `Balance` with exact `rawAmount` plus resolved decimals / symbol / name.
  /// - Throws: RainSDKError if wallet is unavailable or the request fails.
  func getBalance(
    chainId: Int,
    token: Token
  ) async throws -> Balance

  /// Fetches all non-zero balances for the current wallet on the given network.
  /// - Parameter chainId: The target blockchain network identifier.
  /// - Returns: One `Balance` per non-zero token plus the native balance (always included).
  /// - Throws: RainSDKError if wallet is unavailable or the request fails.
  func getBalances(
    chainId: Int
  ) async throws -> [Balance]

  /// Fetches transaction history for the current wallet on the given network.
  /// - Parameters:
  ///   - chainId: The target blockchain network identifier.
  ///   - limit: Optional maximum number of transactions to return.
  ///   - offset: Optional offset for pagination.
  ///   - order: Optional sort order (e.g. newest first).
  /// - Returns: List of high-level `WalletTransaction` records.
  /// - Throws: RainSDKError if wallet is unavailable or the request fails.
  func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction]
}

