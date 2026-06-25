import Foundation

internal protocol RainTypedDataSignerProvider: Sendable {
  func signTypedData(
    chainId: Int,
    walletAddress: String,
    typedData: String
  ) async throws -> String
}

internal protocol RainTransactionFeeEstimatingProvider: Sendable {
  func estimateTransactionFee(
    chainId: Int,
    walletAddress: String,
    params: WalletTransactionParams
  ) async throws -> Double
}

/// Solana transfers (native SOL + SPL tokens). Implemented by providers that manage a Solana
/// account (e.g. Turnkey).
///
/// SOL amounts are scaled at 1e9 lamports, SPL token amounts at the mint's `decimals` — both
/// paths get a dedicated entry point rather than flowing through the EVM `WalletTransactionParams`
/// (1e18-scaled hex `value`).
internal protocol RainSolanaTransfersProvider: Sendable {
  /// Signs and broadcasts a native SOL transfer.
  ///
  /// - Parameters:
  ///   - chainId: Solana sentinel chain ID (101 / 102 / 103).
  ///   - to: Recipient base58 address.
  ///   - amount: Human-readable SOL amount (e.g. 0.5).
  /// - Returns: The Solana transaction signature.
  func sendSolanaNative(
    chainId: Int,
    to toAddress: String,
    amount: Double
  ) async throws -> String

  /// Signs and broadcasts an SPL token transfer (TransferChecked instruction, auto-creating
  /// the recipient associated token account when needed).
  ///
  /// - Parameters:
  ///   - chainId: Solana sentinel chain ID (101 / 102 / 103).
  ///   - mintAddress: SPL mint address (base58).
  ///   - to: Recipient wallet base58 address (NOT the recipient ATA — the SDK derives that).
  ///   - amount: Human-readable token amount (e.g. 1.5 for 1.5 USDC).
  ///   - decimals: Number of decimals the SPL mint uses (e.g. 6 for USDC).
  /// - Returns: The Solana transaction signature.
  func sendSolanaSPLToken(
    chainId: Int,
    mintAddress: String,
    to toAddress: String,
    amount: Double,
    decimals: Int
  ) async throws -> String
}
