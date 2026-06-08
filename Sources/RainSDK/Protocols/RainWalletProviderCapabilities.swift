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

/// Native SOL transfers. Implemented by providers that manage a Solana account (Turnkey).
/// SOL amounts are scaled at 1e9 lamports, so they get a dedicated entry point rather than
/// flowing through the EVM `WalletTransactionParams` (1e18-scaled hex `value`).
internal protocol RainSolanaTransfersProvider: Sendable {
  func sendSolanaNative(
    chainId: Int,
    to toAddress: String,
    amount: Double
  ) async throws -> String
}
