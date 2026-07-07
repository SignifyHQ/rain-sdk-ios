import Testing
import Foundation
import RainCore
@testable import RainPrivy

/// Mirrors the Android `PrivyProviderTest`. Asserts the descriptor's id/capabilities and that the
/// (skeleton) resolved wallet provider throws for `address()`.
@Suite("Privy Provider Tests")
struct PrivyProviderTest {

  @Test("descriptor advertises the privy id and capabilities")
  func descriptorAdvertisesIdAndCapabilities() {
    let provider = PrivyProvider(PrivyConfig(appId: "app-id"))
    #expect(provider.id == .privy)
    #expect(provider.capabilities == [.export, .recovery])
  }

  @Test("resolved wallet provider operations are not implemented yet")
  func walletProviderOperationsNotImplemented() async throws {
    let rain = try RainSdk.builder()
      .rpcEndpoints([1: "https://mainnet.infura.io/v3/test"])
      .register(PrivyProvider(PrivyConfig(appId: "app-id")))
      .build()

    let client = try await rain.provider(.privy)

    await #expect(throws: RainSDKError.self) {
      _ = try await client.getWalletAddress()
    }
  }
}
