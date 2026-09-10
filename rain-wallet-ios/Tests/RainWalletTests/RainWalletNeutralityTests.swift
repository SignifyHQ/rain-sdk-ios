import Testing
import Foundation
import Combine
import RainWallet // deliberately the ONLY SDK import — see below

/// Compiles against a bare `import RainWallet`, proving the module's public surface is complete
/// and wallet-neutral: everything an integrator writes (config, descriptor, auth, session, the
/// re-exported core) is expressible without importing — or ever seeing — any other module.
/// If a vendor type leaked into a public signature, this file would stop compiling.
///
/// The full integration flow lives in a deliberately UNEXECUTED closure: compiling it is the
/// guarantee; running it would touch the process-wide wallet backend, which this file — by
/// design — has no test seams to stub.
@Suite("RainWallet Neutrality")
struct RainWalletNeutralityTests {
  /// Never called. Type-checks the complete integration surface with module-owned names only.
  private static func integrationSurface() async throws {
    let provider = RainProvider(
      RainWalletConfig(
        organizationId: "org",
        authConfigId: "auth",
        walletAddress: nil,
        sessionPolicy: RainWalletSessionPolicy(autoRefresh: true),
        onSessionExpired: {}
      )
    )

    // Auth + session surface, fully typed with module-owned names.
    let _: RainWalletAuthState = provider.authState
    let _: AnyPublisher<RainWalletAuthState, Never> = provider.authStates
    await provider.awaitSessionRestore(timeout: 1)
    if !provider.hasActiveSession() {
      try await provider.sendLoginCode(email: "user@example.com")
      try await provider.confirmLoginCode("123456")
    }
    let _: AnyPublisher<RainWalletSessionState, Never> = provider.sessionState
    let _: RainWalletSessionState = provider.currentSessionState()
    try await provider.refreshSession()
    try await provider.logout()
    provider.close()

    // The re-exported core surface resolves through this one import.
    let rain: RainSdk = try RainSdk.builder()
      .rpcEndpoints([1: "https://mainnet.test"])
      .register(provider)
      .build()
    let client: any RainClient = try await rain.provider(.rain)
    _ = try await client.getWalletAddress()
  }

  @Test("the neutral integration surface compiles with a bare import RainWallet")
  func testPublicSurface() {
    // The compile of `integrationSurface` is the assertion. Runtime checks stay to the
    // side-effect-free corners of the surface.
    _ = Self.integrationSurface

    let expired: RainWalletSessionState = .expired
    #expect(expired != .unauthenticated)
    #expect(RainWalletAuthState.authenticated == .authenticated)
    let policy = RainWalletSessionPolicy()
    #expect(policy.autoRefresh)
    let error: RainSDKError = .tokenExpired // re-exported core type
    #expect(error == .tokenExpired)
    #expect(ProviderId.rain.rawValue == "rain")
  }
}
