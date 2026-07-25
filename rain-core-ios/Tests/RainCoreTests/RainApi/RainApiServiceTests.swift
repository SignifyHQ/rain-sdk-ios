import Testing
import Foundation
@testable import RainCore

@Suite("RainApiService Tests", .serialized)
struct RainApiServiceTests {
  private static let sessionJson =
    #"{"token":"cst_abc","expiresAt":"2030-01-01T00:00:00Z","userId":"user"}"#

  /// One contract on an unknown chain (999888) with one unknown token, so the token store
  /// always enriches through the chain reader rather than the built-in registry.
  private static let contractsJson = #"""
  [
    {
      "chainId": 999888,
      "controllerAddress": "0xcontroller",
      "proxyAddress": "0xproxy",
      "adminAddresses": ["0xadmin"],
      "tokens": [
        {"address": "0xtokenunknown", "balance": "12.5", "exchangeRate": 1.0, "advanceRate": 0.8}
      ]
    }
  ]
  """#

  private func makeService(
    chainReader: MockChainReader = MockChainReader(),
    configure: Bool = true
  ) -> RainApiService {
    let configStore = RainApiConfigStore(baseURL: URL(string: "https://rain-api.test")!)
    if configure {
      configStore.setCredentials(apiKey: "key", userId: "user")
    }
    return RainApiService(
      configStore: configStore,
      tokenStore: TokenMetadataStore(chainReader: chainReader),
      chainReader: chainReader,
      client: RainApiClient(session: MockRainApiURLProtocol.makeSession())
    )
  }

  @Test("throws rainApiNotConfigured before credentials are set")
  func notConfigured() async throws {
    await MockRainApiURLProtocol.withStubs {
      await #expect(throws: RainSDKError.rainApiNotConfigured) {
        _ = try await makeService(configure: false).fetchCollateralContracts()
      }
    }
  }

  @Test("401 on a data call re-mints the session and retries once")
  func retryOnceOn401() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/sessions", .init(json: Self.sessionJson))
      MockRainApiURLProtocol.stub(
        "/contracts",
        .init(statusCode: 401, json: "expired"),
        .init(json: Self.contractsJson)
      )

      let contracts = try await makeService().fetchCollateralContracts()

      #expect(contracts.count == 1)
      #expect(MockRainApiURLProtocol.recordedRequests(pathSuffix: "/sessions").count == 2)
    }
  }

  @Test("persistent 401 surfaces unauthorized after one retry")
  func persistent401() async throws {
    await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/sessions", .init(json: Self.sessionJson))
      MockRainApiURLProtocol.stub("/contracts", .init(statusCode: 401, json: "nope"))

      await #expect(throws: RainSDKError.unauthorized) {
        _ = try await makeService().fetchCollateralContracts()
      }
      #expect(MockRainApiURLProtocol.recordedRequests(pathSuffix: "/contracts").count == 2)
    }
  }

  @Test("enriches token metadata through the token store")
  func enrichesTokens() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/sessions", .init(json: Self.sessionJson))
      MockRainApiURLProtocol.stub("/contracts", .init(json: Self.contractsJson))

      let chainReader = MockChainReader()
      chainReader.stubbedDecimals = 6
      chainReader.stubbedSymbol = "USDC"
      chainReader.stubbedName = "USD Coin"

      let contracts = try await makeService(chainReader: chainReader).fetchCollateralContracts()

      let token = try #require(contracts.first?.tokens.first)
      #expect(token.symbol == "USDC")
      #expect(token.name == "USD Coin")
      #expect(token.decimals == 6)
      #expect(token.balance == "12.5")
    }
  }

  @Test("failed metadata reads leave name, symbol AND decimals nil")
  func enrichmentFailureLeavesNil() async throws {
    // A fabricated decimals default (e.g. 18) would corrupt the caller's base-unit math,
    // so a failed read must surface as nil — the fetch itself still succeeds.
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/sessions", .init(json: Self.sessionJson))
      MockRainApiURLProtocol.stub("/contracts", .init(json: Self.contractsJson))

      let chainReader = MockChainReader()
      chainReader.stubbedMetadataError = URLError(.cannotConnectToHost)

      let contracts = try await makeService(chainReader: chainReader).fetchCollateralContracts()

      let token = try #require(contracts.first?.tokens.first)
      #expect(token.symbol == nil)
      #expect(token.name == nil)
      #expect(token.decimals == nil)
      #expect(token.balance == "12.5")
    }
  }

  @Test("registered token resolves without any on-chain read")
  func registeredTokenSkipsChainReads() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/sessions", .init(json: Self.sessionJson))
      MockRainApiURLProtocol.stub("/contracts", .init(json: Self.contractsJson))

      let chainReader = MockChainReader()
      let tokenStore = TokenMetadataStore(chainReader: chainReader)
      await tokenStore.register([
        TokenInfo(chainId: 999_888, address: "0xTOKENUNKNOWN", symbol: "REG", decimals: 8, name: "Registered")
      ])
      let configStore = RainApiConfigStore(baseURL: URL(string: "https://rain-api.test")!)
      configStore.setCredentials(apiKey: "key", userId: "user")
      let service = RainApiService(
        configStore: configStore,
        tokenStore: tokenStore,
        chainReader: chainReader,
        client: RainApiClient(session: MockRainApiURLProtocol.makeSession())
      )

      let token = try #require(try await service.fetchCollateralContracts().first?.tokens.first)

      #expect(token.symbol == "REG")
      #expect(token.decimals == 8)
      #expect(chainReader.decimalsCalls.isEmpty)
      #expect(chainReader.symbolCalls.isEmpty)
    }
  }

  @Test("Solana tokens enrich from the registry only; unregistered mints stay bare")
  func solanaEnrichmentIsRegistryOnly() async throws {
    // The on-chain read path is EVM-only and SPL mints carry no on-chain symbol, so
    // host-registered metadata is the sole naming source on Solana chains.
    let solanaContractsJson = #"""
    [
      {
        "chainId": 901,
        "controllerAddress": "",
        "proxyAddress": "CollateralAccount",
        "adminAddresses": [],
        "tokens": [
          {"address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", "balance": "10", "exchangeRate": 1.0, "advanceRate": 0.8},
          {"address": "So11111111111111111111111111111111111111112", "balance": "1", "exchangeRate": 1.0, "advanceRate": 0.8}
        ]
      }
    ]
    """#
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/sessions", .init(json: Self.sessionJson))
      MockRainApiURLProtocol.stub("/contracts", .init(json: solanaContractsJson))

      let chainReader = MockChainReader()
      let tokenStore = TokenMetadataStore(chainReader: chainReader)
      await tokenStore.register([
        TokenInfo(
          chainId: 901,
          address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
          symbol: "USDC",
          decimals: 6,
          name: "USD Coin"
        )
      ])
      let configStore = RainApiConfigStore(baseURL: URL(string: "https://rain-api.test")!)
      configStore.setCredentials(apiKey: "key", userId: "user")
      let service = RainApiService(
        configStore: configStore,
        tokenStore: tokenStore,
        chainReader: chainReader,
        client: RainApiClient(session: MockRainApiURLProtocol.makeSession())
      )

      let tokens = try #require(try await service.fetchCollateralContracts().first?.tokens)

      #expect(tokens[0].symbol == "USDC")
      #expect(tokens[0].name == "USD Coin")
      #expect(tokens[0].decimals == 6)
      #expect(tokens[1].symbol == nil)
      #expect(tokens[1].decimals == nil)
      #expect(chainReader.decimalsCalls.isEmpty)
      #expect(chainReader.symbolCalls.isEmpty)
    }
  }

  @Test("fetchAdminSignature returns the mapped signature")
  func adminSignaturePassthrough() async throws {
    try await MockRainApiURLProtocol.withStubs {
      MockRainApiURLProtocol.stub("/sessions", .init(json: Self.sessionJson))
      MockRainApiURLProtocol.stub(
        "/signatures/withdrawals",
        .init(json: #"{"status":"ready","signature":{"data":"0xsig","salt":"0xsalt"},"expiresAt":"2030-01-01T00:00:00Z"}"#)
      )

      let signature = try await makeService().fetchAdminSignature(
        chainId: 999_888,
        tokenAddress: "0xtoken",
        amountBaseUnits: "10",
        adminAddress: "0xadmin",
        recipientAddress: "0xrecipient",
        isAmountNative: true
      )

      #expect(signature.signature == "0xsig")
      #expect(signature.salt == "0xsalt")
      #expect(signature.expiresAt == "2030-01-01T00:00:00Z")
    }
  }
}
