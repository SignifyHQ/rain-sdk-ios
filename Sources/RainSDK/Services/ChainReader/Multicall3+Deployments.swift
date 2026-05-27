import Foundation

extension Multicall3 {
  /// Mainnet Rain chain IDs where Multicall3 is at `canonicalAddress`.
  /// Used to batch read native + ERC-20 balances.
  static let canonicallyDeployedChainIds: Set<Int> = [
    1,       // Ethereum
    10,      // Optimism
    56,      // BNB Chain
    137,     // Polygon
    143,     // Monad
    324,     // zkSync Era
    8453,    // Base
    9745,    // Plasma
    42161,   // Arbitrum
    42220,   // Celo
    43114,   // Avalanche
    57073,   // Ink
  ]

  /// True when Multicall3 is known-deployed at `canonicalAddress` on the given chain.
  static func isCanonicallyDeployed(on chainId: Int) -> Bool {
    canonicallyDeployedChainIds.contains(chainId)
  }
}
