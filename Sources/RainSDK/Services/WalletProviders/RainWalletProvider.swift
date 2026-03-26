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

  /// Fetches the native token balance (e.g. ETH) for the current wallet on the given network.
  /// - Parameter chainId: The target blockchain network identifier.
  /// - Returns: Balance in human-readable form (e.g. 1.5 for 1.5 ETH). Returns 0 if the wallet has no native balance.
  /// - Throws: RainSDKError if wallet is unavailable or the RPC request fails.
  func getNativeBalance(
    chainId: Int
  ) async throws -> Double

  /// Fetches the ERC-20 balance for a single token via direct RPC `eth_call` (balanceOf).
  /// - Parameters:
  ///   - chainId: The target blockchain network identifier.
  ///   - tokenAddress: The ERC-20 token contract address.
  ///   - decimals: Token decimal places (e.g. 6 for USDC, 18 for most tokens). Defaults to 18.
  /// - Returns: Balance in human-readable form (e.g. 100.0 for 100 tokens).
  /// - Throws: RainSDKError if wallet is unavailable or the RPC request fails.
  func getERC20Balance(
    chainId: Int,
    tokenAddress: String,
    decimals: Int?
  ) async throws -> Double

  /// Fetches ERC-20 token balances for the current wallet on the given network.
  /// - Parameter chainId: The target blockchain network identifier.
  /// - Returns: Dictionary mapping token contract address to balance (human-readable).
  /// - Throws: RainSDKError if wallet is unavailable or the request fails.
  func getERC20Balances(
    chainId: Int
  ) async throws -> [String: Double]

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

