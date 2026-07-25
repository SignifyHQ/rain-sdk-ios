import Foundation

/// Chain IDs for the networks Rain supports out of the box. Mirrors Android's `RainChain`.
/// Solana has no EIP-155 ID, so the SDK uses Rain's own chain IDs (900 = mainnet-beta,
/// 901 = devnet — the values the Rain issuing API returns in collateral contracts and expects
/// on withdrawal-signature requests). Rain assigns no ID to the testnet cluster; 902 extends
/// the scheme for SDK-internal use only.
public enum RainChain {
  public static let avalancheMainnet = 43114
  public static let avalancheTestnet = 43113

  public static let solanaMainnet = 900
  public static let solanaTestnet = 902
  public static let solanaDevnet = 901

  /// Public accessors over the `internal` `SolanaChains` so out-of-core adapters (Privy, Portal)
  /// can route Solana chains.
  public static func isSolana(_ chainId: Int) -> Bool { SolanaChains.isSolana(chainId) }
  public static func solanaCaip2(for chainId: Int) -> String? { SolanaChains.caip2(for: chainId) }
}
