import Foundation

/// Chain IDs for the networks Rain supports out of the box. Mirrors Android's `RainChain`.
/// Solana has no EIP-155 ID, so the SDK uses wallet-adapter sentinel IDs (101/102/103).
public enum RainChain {
  public static let avalancheMainnet = 43114
  public static let avalancheTestnet = 43113

  public static let solanaMainnet = 101
  public static let solanaTestnet = 102
  public static let solanaDevnet = 103
}
