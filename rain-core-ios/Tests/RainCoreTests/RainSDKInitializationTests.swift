import Testing
import Foundation
@testable import RainCore

/// Rewritten for the modular registry API. The monolith's `RainSDKManager()` +
/// `initializePortal` / `initialize` / provider-access lifecycle no longer exists; the
/// equivalent validation now lives on `RainSdk.builder().build()`. Portal-specific init
/// validation (empty session token, RPC config) moved to `RainPortalTests`.
@Suite("SDK Initialization Tests")
struct SDKInitializationTests {

  /// Minimal `RainProvider` so the builder has something to register — resolving it yields a
  /// `StubWalletProvider`. Lets these tests exercise builder validation without a vendor SDK.
  private struct StubProvider: RainProvider {
    var id: ProviderId = .turnkey
    var capabilities: Set<Capability> = []
    func create(context: ProviderContext) async throws -> any RainWalletProvider {
      StubWalletProvider()
    }
  }

  // MARK: - builder() validation

  @Test("build succeeds with valid configs and a registered provider")
  func testBuildSuccess() throws {
    let sdk = try RainSdk.builder()
      .rpcEndpoints([
        NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test"),
        NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")
      ])
      .register(StubProvider())
      .build()
    #expect(sdk.providerIds.contains(.turnkey))
  }

  /// Runs `body`, expecting `.invalidConfig` whose details equal `expectedDetails`.
  private func expectInvalidConfig(
    details expectedDetails: String,
    _ body: () throws -> Void
  ) {
    do {
      try body()
      Issue.record("Expected invalidConfig, but no error was thrown")
    } catch let error as RainSDKError {
      guard case .invalidConfig(let details) = error else {
        Issue.record("Expected .invalidConfig, got \(error)")
        return
      }
      #expect(details == expectedDetails)
    } catch {
      Issue.record("Expected RainSDKError.invalidConfig, got \(error)")
    }
  }

  @Test("build throws invalidConfig for empty configs")
  func testBuildEmptyConfigs() throws {
    expectInvalidConfig(details: "At least one RPC endpoint is required") {
      _ = try RainSdk.builder().register(StubProvider()).build()
    }
  }

  @Test("build throws invalidConfig for zero chain ID")
  func testBuildInvalidChainIdZero() throws {
    expectInvalidConfig(details: "Invalid RPC endpoint for chainId 0: https://test-rpc.com") {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: 0)])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build throws invalidConfig for negative chain ID")
  func testBuildInvalidChainIdNegative() throws {
    expectInvalidConfig(details: "Invalid RPC endpoint for chainId -1: https://test-rpc.com") {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: -1)])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build throws invalidConfig for empty RPC URL")
  func testBuildEmptyRpcUrl() throws {
    expectInvalidConfig(details: "Invalid RPC endpoint for chainId 1: ") {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: 1, rpcUrl: "")])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build throws invalidConfig for URL without scheme")
  func testBuildRpcUrlMissingScheme() throws {
    expectInvalidConfig(details: "Invalid RPC endpoint for chainId 1: not-a-valid-url") {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: 1, rpcUrl: "not-a-valid-url")])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build throws invalidConfig for non-HTTP scheme")
  func testBuildRpcUrlNonHttpScheme() throws {
    expectInvalidConfig(details: "Invalid RPC endpoint for chainId 1: ftp://example.com") {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: 1, rpcUrl: "ftp://example.com")])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build with no provider succeeds (wallet-agnostic) but resolving a provider throws")
  func testBuildNoProvider() async throws {
    // Building with no registered provider is allowed — it yields a wallet-agnostic RainSdk whose
    // transaction-building methods work; resolving a provider is what throws.
    let sdk = try RainSdk.builder()
      .rpcEndpoints([NetworkConfig.testConfig(chainId: 1)])
      .build()

    await #expect(throws: RainSDKError.providerNotRegistered(details: "No provider registered for id 'portal'")) {
      _ = try await sdk.provider(.portal)
    }
  }

  // MARK: - Provider resolution

  @Test("provider(_:) throws providerNotRegistered for an unregistered id")
  func testResolveUnregisteredProvider() async throws {
    let sdk = try RainSdk.builder()
      .rpcEndpoints([NetworkConfig.testConfig(chainId: 1)])
      .register(StubProvider())
      .build()

    await #expect(throws: RainSDKError.providerNotRegistered(details: "No provider registered for id 'privy'")) {
      _ = try await sdk.provider(.privy)
    }
  }

  @Test("rpcEndpoints([chainId: rpcUrl]) map form builds equivalent configs")
  func testBuildFromRpcMap() throws {
    let sdk = try RainSdk.builder()
      .rpcEndpoints([1: "https://mainnet.com", 137: "https://polygon.com"])
      .register(StubProvider())
      .build()
    #expect(sdk.providerIds == [.turnkey])
  }

  // MARK: - Client metadata

  @Test("resolved client exposes providerId, capabilities and isInitialized")
  func testClientMetadata() async throws {
    let sdk = try RainSdk.builder()
      .rpcEndpoints([NetworkConfig.testConfig(chainId: 1)])
      .register(StubProvider(capabilities: [.export, .recovery]))
      .build()

    let client = try await sdk.provider(.turnkey)
    #expect(client.providerId == .turnkey)
    #expect(client.capabilities == [.export, .recovery])
    #expect(client.isInitialized)
  }

  // MARK: - reset()

  @Test("reset evicts resolved clients and clears Rain API credentials; the SDK stays usable")
  func testReset() async throws {
    let sdk = try RainSdk.builder()
      .rpcEndpoints([NetworkConfig.testConfig(chainId: 1)])
      .register(StubProvider())
      .rainApiCredentials(apiKey: "key", userId: "user")
      .build()

    let first = try await sdk.provider(.turnkey)
    #expect(sdk.isRainApiConfigured)

    sdk.reset()
    #expect(!sdk.isRainApiConfigured)

    // The instance stays usable after reset: the next resolution re-runs create(context:)
    // and yields a fresh client.
    let second = try await sdk.provider(.turnkey)
    let firstIdentity = ObjectIdentifier(first as AnyObject)
    let secondIdentity = ObjectIdentifier(second as AnyObject)
    #expect(firstIdentity != secondIdentity)
  }

  @Test("reset is idempotent and client-level reset is a safe no-op")
  func testResetIdempotent() async throws {
    let sdk = try RainSdk.builder()
      .rpcEndpoints([NetworkConfig.testConfig(chainId: 1)])
      .register(StubProvider())
      .build()

    let client = try await sdk.provider(.turnkey)
    client.reset() // parity no-op; must not throw or corrupt the client
    _ = try await client.getWalletAddress()

    sdk.reset()
    sdk.reset()
    _ = try await sdk.provider(.turnkey)
  }

  // MARK: - Turnkey test seam

  @Test("Turnkey-backed manager resolves the wallet address")
  func testTurnkeyManagerResolvesAddress() async throws {
    let (manager, _, _) = TestManagers.turnkeyManager()

    let walletAddress = try await manager.getWalletAddress()
    #expect(walletAddress == MockTurnkey.defaultWalletAddress)
  }
}
