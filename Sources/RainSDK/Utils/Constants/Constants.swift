import Foundation

public enum Constants {
  /// ERC-20 token defaults
  enum ERC20 {
    /// Default number of decimal places for ERC-20 tokens (e.g. USDC uses 6, most tokens use 18)
    static let defaultDecimals = 18
  }

  /// Contract ABI JSON names
  /// Used to identify contract ABIs for encoding/decoding operations
  enum ContractABI {
    /// Main contract ABI JSON name
    static let contractJsonABI = "contractJsonABI"

    /// Collateral contract ABI JSON name
    static let collateralJsonABI = "collateralJsonABI"
  }

  /// Chains for which the Turnkey `get-balances` API returns data.
  /// On any other chain, balance reads fall through to `ChainReader`.
  /// Source: https://docs.turnkey.com/api-reference/queries/get-balances
  static let turnkeySupportedChains: Set<Int> = [
    1,        // Ethereum Mainnet
    11155111, // Sepolia
    8453,     // Base Mainnet
    84532,    // Base Sepolia
    137,      // Polygon Mainnet
    80002     // Polygon Amoy
  ]
}
