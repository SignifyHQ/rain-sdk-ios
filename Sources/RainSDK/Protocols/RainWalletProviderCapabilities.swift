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
