import Foundation

/// Describes an on-chain ERC-20 token the SDK can read balances for.
internal struct TokenSpec: Sendable, Equatable {
  /// EIP-155 chain ID
  let chainId: Int

  /// Token contract address
  let address: String

  /// Token symbol (e.g. "USDC", "DAI")
  let symbol: String

  /// Number of decimal places (e.g. 6 for USDC, 18 for DAI)
  let decimals: Int

  /// Optional human-readable token name
  let name: String?

  init(
    chainId: Int,
    address: String,
    symbol: String,
    decimals: Int,
    name: String? = nil
  ) {
    self.chainId = chainId
    self.address = address
    self.symbol = symbol
    self.decimals = decimals
    self.name = name
  }
}
