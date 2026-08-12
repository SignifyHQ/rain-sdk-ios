import Testing
import Foundation
@testable import RainCore

/// Keeps the Auth Pull chain sets honest against Rain's published support matrix and against the
/// other in-tree lists an approval depends on.
@Suite("Auth Pull Chain Tests")
struct RainAuthPullChainsTests {

  @Test("sandbox is Base Sepolia and Arbitrum Sepolia")
  func sandboxSet() {
    #expect(RainAuthPullChains.sandbox == [84532, 421614])
  }

  @Test("production is Base and Arbitrum mainnet")
  func productionSet() {
    #expect(RainAuthPullChains.production == [8453, 42161])
  }

  @Test("the two environments share no chain")
  func environmentsAreDisjoint() {
    #expect(RainAuthPullChains.sandbox.isDisjoint(with: RainAuthPullChains.production))
  }

  @Test("dev resolves to sandbox and production to production")
  func environmentMapping() {
    #expect(RainAuthPullChains.supported(for: .dev) == RainAuthPullChains.sandbox)
    #expect(RainAuthPullChains.supported(for: .production) == RainAuthPullChains.production)
  }

  @Test("a custom base url fails closed")
  func customFailsClosed() throws {
    let url = try #require(URL(string: "https://gateway.example.com"))

    #expect(RainAuthPullChains.supported(for: .custom(url)).isEmpty)
  }

  @Test("isSupported agrees with supported")
  func isSupportedAgrees() {
    #expect(RainAuthPullChains.isSupported(chainId: 84532, in: .dev))
    #expect(!RainAuthPullChains.isSupported(chainId: 8453, in: .dev))
    #expect(RainAuthPullChains.isSupported(chainId: 8453, in: .production))
    #expect(!RainAuthPullChains.isSupported(chainId: 1, in: .production))
  }

  /// The approval path resolves USDC's decimals from `TokenRegistry`, and refuses to guess. An
  /// Auth Pull chain with no registry entry would force every host to pass `decimals` by hand.
  @Test("every Auth Pull chain ships USDC in the token registry")
  func everyChainHasUsdc() {
    for chainId in RainAuthPullChains.sandbox.union(RainAuthPullChains.production) {
      let usdc = TokenRegistry.tokens(for: chainId).filter { $0.symbol == "USDC" }
      #expect(usdc.count == 1, "chain \(chainId) has \(usdc.count) USDC entries")
      #expect(usdc.first?.decimals == 6)
    }
  }

  /// Allowance reads batch through Multicall3 where it is deployed; all four qualify.
  @Test("every Auth Pull chain has a canonical Multicall3 deployment")
  func everyChainHasMulticall3() {
    for chainId in RainAuthPullChains.sandbox.union(RainAuthPullChains.production) {
      #expect(Multicall3.isCanonicallyDeployed(on: chainId), "chain \(chainId)")
    }
  }

  /// ERC-20 approvals are EVM-only, so no Solana sentinel may leak into either set.
  @Test("no Auth Pull chain is a Solana sentinel")
  func noSolanaSentinels() {
    for chainId in RainAuthPullChains.sandbox.union(RainAuthPullChains.production) {
      #expect(!RainChain.isSolana(chainId), "chain \(chainId)")
    }
  }
}
