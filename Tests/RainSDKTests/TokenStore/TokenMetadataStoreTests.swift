import Testing
import Foundation
@testable import RainSDK

@Suite("TokenMetadataStore Tests")
struct TokenMetadataStoreTests {
  /// An address not present in `TokenRegistry`, used to force the enrichment path.
  static let unknownToken = "0x00000000000000000000000000000000000000ff"

  @Test("known registry token resolves without any enrichment RPC")
  func testKnownTokenResolvesWithoutEnrichment() async throws {
    let reader = MockChainReader()
    let store = TokenMetadataStore(chainReader: reader)

    let info = await store.tokenInfo(chainId: 1, address: TestFixtures.usdcAddress)

    #expect(info.symbol == "USDC")
    #expect(info.decimals == 6)
    #expect(reader.decimalsCalls.isEmpty)
    #expect(reader.symbolCalls.isEmpty)
  }

  @Test("unknown token enriches exactly once, then serves from cache")
  func testUnknownTokenEnrichesOnceThenCaches() async throws {
    let reader = MockChainReader()
    reader.stubbedDecimals = 8
    reader.stubbedSymbol = "WBTC"
    reader.stubbedName = "Wrapped BTC"
    let store = TokenMetadataStore(chainReader: reader)

    let first = await store.tokenInfo(chainId: 1, address: Self.unknownToken)
    #expect(first.decimals == 8)
    #expect(first.symbol == "WBTC")
    #expect(first.name == "Wrapped BTC")
    #expect(reader.decimalsCalls.count == 1)
    #expect(reader.symbolCalls.count == 1)
    #expect(reader.nameCalls.count == 1)

    // Second lookup must hit the cache — no extra RPC.
    let second = await store.tokenInfo(chainId: 1, address: Self.unknownToken)
    #expect(second == first)
    #expect(reader.decimalsCalls.count == 1)
    #expect(reader.symbolCalls.count == 1)
    #expect(reader.nameCalls.count == 1)
  }

  @Test("register makes a previously-unknown token resolve without enrichment")
  func testRegisterAvoidsEnrichment() async throws {
    let reader = MockChainReader()
    let store = TokenMetadataStore(chainReader: reader)

    await store.register([
      TokenInfo(chainId: 1, address: Self.unknownToken, symbol: "FOO", decimals: 12, name: "Foo Token")
    ])

    let info = await store.tokenInfo(chainId: 1, address: Self.unknownToken)
    #expect(info.symbol == "FOO")
    #expect(info.decimals == 12)
    #expect(info.name == "Foo Token")
    #expect(reader.decimalsCalls.isEmpty)
    #expect(reader.symbolCalls.isEmpty)
  }

  @Test("seedTokens resolve without enrichment")
  func testSeedTokensResolveWithoutEnrichment() async throws {
    let reader = MockChainReader()
    let store = TokenMetadataStore(
      chainReader: reader,
      seedTokens: [TokenInfo(chainId: 1, address: Self.unknownToken, symbol: "BAR", decimals: 4, name: nil)]
    )

    let info = await store.tokenInfo(chainId: 1, address: Self.unknownToken)
    #expect(info.symbol == "BAR")
    #expect(info.decimals == 4)
    #expect(reader.decimalsCalls.isEmpty)
    #expect(reader.symbolCalls.isEmpty)
  }

  @Test("token lookup is case-insensitive on address")
  func testCaseInsensitiveLookup() async throws {
    let reader = MockChainReader()
    let store = TokenMetadataStore(chainReader: reader)

    let lower = await store.tokenInfo(chainId: 1, address: TestFixtures.usdcAddress.lowercased())
    let upper = await store.tokenInfo(chainId: 1, address: TestFixtures.usdcAddress.uppercased())

    #expect(lower.symbol == "USDC")
    #expect(upper.symbol == "USDC")
    #expect(reader.decimalsCalls.isEmpty)
    #expect(reader.symbolCalls.isEmpty)
  }

  @Test("nativeCurrency returns chain-specific metadata")
  func testNativeCurrencyLookup() async throws {
    let reader = MockChainReader()
    let store = TokenMetadataStore(chainReader: reader)

    let eth = await store.nativeCurrency(for: 1)
    #expect(eth.symbol == "ETH")

    let avax = await store.nativeCurrency(for: 43114)
    #expect(avax.symbol == "AVAX")
  }
}
