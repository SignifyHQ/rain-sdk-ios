import Testing
import Foundation
@testable import RainCore
@_spi(RainWallet) @testable import RainTurnkey
@testable import RainWallet

@Suite("RainWallet")
struct RainWalletTests {
  /// Constructing a `RainProvider` configures the process-wide wallet backend and grabs the
  /// vendor singleton (which traps when unconfigured in a test host) — stub both seams so unit
  /// tests never touch real keychain/session machinery.
  init() {
    TurnkeyManagedConfigurator.configureImpl = { _, _ in }
    TurnkeyManagedConfigurator.sharedContext = { StubBackendContext() }
  }

  // MARK: - State mapping

  @Test("session states map one-to-one onto the neutral enum")
  func testSessionStateMapping() {
    #expect(RainWalletSessionState(TurnkeySessionState.loading) == .loading)
    #expect(RainWalletSessionState(TurnkeySessionState.active(expiresAt: 42)) == .active(expiresAt: 42))
    #expect(RainWalletSessionState(TurnkeySessionState.expired) == .expired)
    #expect(RainWalletSessionState(TurnkeySessionState.unauthenticated) == .unauthenticated)
  }

  @Test("auth states map one-to-one onto the neutral enum")
  func testAuthStateMapping() {
    #expect(RainWalletAuthState(TurnkeyAuthState.loading) == .loading)
    #expect(RainWalletAuthState(TurnkeyAuthState.authenticated) == .authenticated)
    #expect(RainWalletAuthState(TurnkeyAuthState.unauthenticated) == .unauthenticated)
  }

  @Test("the session policy maps every field onto the backing policy")
  func testSessionPolicyMapping() {
    let policy = RainWalletSessionPolicy(
      refreshBufferSeconds: 30,
      autoRefresh: false,
      refreshExpirationSeconds: "1200",
      maxTransientRetries: 5,
      initialRetryDelay: 1,
      maxRetryDelay: 8
    )
    let backing = policy.backingPolicy
    #expect(backing.refreshBufferSeconds == 30)
    #expect(backing.autoRefresh == false)
    #expect(backing.refreshExpirationSeconds == "1200")
    #expect(backing.maxTransientRetries == 5)
    #expect(backing.initialRetryDelay == 1)
    #expect(backing.maxRetryDelay == 8)
  }

  // MARK: - Descriptor

  @Test("the descriptor advertises the .rain id and the backing capabilities")
  func testDescriptorIdentity() {
    let provider = RainProvider(
      RainWalletConfig(organizationId: "org-\(UUID().uuidString)", authConfigId: "auth")
    )
    #expect(provider.id == .rain)
    #expect(provider.capabilities == [.multiChain, .biometricGate])
  }

  // MARK: - Registry exclusion

  @Test("build rejects registering the Rain wallet and Turnkey providers together")
  func testMutualExclusionGuard() {
    struct StubDescriptor: ProviderDescriptor {
      let id: ProviderId
      func create(context: ProviderContext) async throws -> any WalletProvider {
        throw RainSDKError.walletUnavailable
      }
    }
    #expect(throws: RainSDKError.self) {
      _ = try RainSdk.builder()
        .rpcEndpoints([1: "https://mainnet.test"])
        .register(StubDescriptor(id: .rain))
        .register(StubDescriptor(id: .turnkey))
        .build()
    }
    // Either alone is fine.
    #expect(throws: Never.self) {
      _ = try RainSdk.builder()
        .rpcEndpoints([1: "https://mainnet.test"])
        .register(StubDescriptor(id: .rain))
        .build()
    }
  }
}
