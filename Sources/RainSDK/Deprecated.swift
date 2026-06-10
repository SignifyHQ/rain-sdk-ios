//
//  Deprecated.swift
//  RainSDK
//
//  Source-compat shims for the 1.0.0 public API. Slated for removal in the next major version.
//

public extension RainSDK {
  /// Deprecated alias for ``sendToken(chainId:contractAddress:to:amount:decimals:)``.
  @available(*, deprecated, message: "Renamed to sendToken (now also routes Solana SPL). It returns RainTokenTransferResult; read .transactionHash for the hash.")
  func sendERC20Token(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Double,
    decimals: Int
  ) async throws -> String {
    try await sendToken(
      chainId: chainId,
      contractAddress: contractAddress,
      to: to,
      amount: amount,
      decimals: decimals
    ).transactionHash
  }
}
