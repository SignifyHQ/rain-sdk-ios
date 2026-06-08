import Testing
import Foundation
@testable import RainSDK

@Suite("SolanaChains & ChainIDFormat")
struct SolanaChainsTests {
  @Test("sentinel ids map to CAIP-2 and back")
  func sentinelMapping() {
    #expect(SolanaChains.isSolana(SolanaChains.mainnet))
    #expect(SolanaChains.isSolana(SolanaChains.devnet))
    #expect(!SolanaChains.isSolana(1))
    #expect(SolanaChains.caip2(for: SolanaChains.mainnet) == "solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp")
    #expect(SolanaChains.chainId(forCaip2: "solana:EtWTRABZaYq6iMfeYKouRu166VU2xqa1") == SolanaChains.devnet)
    #expect(SolanaChains.nativeCurrency.symbol == "SOL")
    #expect(SolanaChains.nativeCurrency.decimals == 9)
  }

  @Test("ChainIDFormat.namespace routes Solana sentinels to .solana")
  func namespaceRouting() {
    #expect(ChainIDFormat.namespace(for: SolanaChains.mainnet) == .solana)
    #expect(ChainIDFormat.namespace(for: 1) == .EIP155)
  }

  @Test("ChainIDFormat round-trips both families")
  func formatRoundTrips() {
    #expect(ChainIDFormat.EIP155.format(chainId: 1) == "eip155:1")
    #expect(ChainIDFormat.EIP155.parse("eip155:1") == 1)

    let caip2 = ChainIDFormat.solana.format(chainId: SolanaChains.mainnet)
    #expect(caip2 == "solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp")
    #expect(ChainIDFormat.solana.parse(caip2) == SolanaChains.mainnet)
  }

  @Test("native-currency registry returns SOL for Solana sentinels")
  func nativeCurrencyRegistry() {
    let sol = TokenRegistry.nativeCurrency(for: SolanaChains.mainnet)
    #expect(sol.symbol == "SOL")
    #expect(sol.decimals == 9)
  }
}
