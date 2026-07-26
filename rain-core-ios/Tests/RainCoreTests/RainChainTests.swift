import Testing
@testable import RainCore

@Suite("RainChain")
struct RainChainTests {

  @Test("chain IDs are pinned; hosts and the Rain API both switch on them")
  func chainIdsArePinned() {
    #expect(RainChain.avalancheMainnet == 43114)
    #expect(RainChain.avalancheTestnet == 43113)
    #expect(RainChain.solanaMainnet == 900)
    #expect(RainChain.solanaTestnet == 902)
    #expect(RainChain.solanaDevnet == 901)
  }

  @Test("Solana routing recognizes the public sentinel IDs")
  func solanaSentinelsRoute() {
    #expect(SolanaChains.isSolana(RainChain.solanaMainnet))
    #expect(SolanaChains.isSolana(RainChain.solanaTestnet))
    #expect(SolanaChains.isSolana(RainChain.solanaDevnet))
    #expect(!SolanaChains.isSolana(RainChain.avalancheMainnet))
  }
}
