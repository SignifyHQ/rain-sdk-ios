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
    var capabilities: Set<Capability> { [] }
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

  @Test("build throws invalidConfig for empty configs")
  func testBuildEmptyConfigs() throws {
    #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "")) {
      _ = try RainSdk.builder().register(StubProvider()).build()
    }
  }

  @Test("build throws invalidConfig for zero chain ID")
  func testBuildInvalidChainIdZero() throws {
    #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "https://test-rpc.com")) {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: 0)])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build throws invalidConfig for negative chain ID")
  func testBuildInvalidChainIdNegative() throws {
    #expect(throws: RainSDKError.invalidConfig(chainId: -1, rpcUrl: "https://test-rpc.com")) {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: -1)])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build throws invalidConfig for empty RPC URL")
  func testBuildEmptyRpcUrl() throws {
    #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "")) {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: 1, rpcUrl: "")])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build throws invalidConfig for URL without scheme")
  func testBuildRpcUrlMissingScheme() throws {
    #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "not-a-valid-url")) {
      _ = try RainSdk.builder()
        .rpcEndpoints([NetworkConfig.testConfig(chainId: 1, rpcUrl: "not-a-valid-url")])
        .register(StubProvider())
        .build()
    }
  }

  @Test("build throws invalidConfig for non-HTTP scheme")
  func testBuildRpcUrlNonHttpScheme() throws {
    #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "ftp://example.com")) {
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

  // MARK: - Turnkey test seam

  @Test("Turnkey-backed manager resolves the wallet address")
  func testTurnkeyManagerResolvesAddress() async throws {
    let (manager, _, _) = TestManagers.turnkeyManager()

    let walletAddress = try await manager.getWalletAddress()
    #expect(walletAddress == MockTurnkey.defaultWalletAddress)
  }
}
