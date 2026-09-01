import Testing
import Foundation
import RainSDK // sole import on purpose — these tests pin the umbrella's re-export surface

/// Smoke tests for the `RainSDK` migration umbrella: a client importing only `RainSDK` must see
/// the full `RainCore` + `RainPortal` surface.
@Suite("Umbrella Smoke Tests")
struct UmbrellaSmokeTests {

  @Test("RainCore and RainPortal entry points resolve through the umbrella")
  func testReExportedSurface() throws {
    // Turnkey ships inside RainCore — its descriptor type must be visible through the umbrella.
    _ = TurnkeyProvider.self

    let rain = try RainSdk.builder()
      .rpcEndpoints([NetworkConfig(chainId: 1, rpcUrl: "https://mainnet.example/rpc")])
      .register(PortalProvider(PortalConfig(sessionToken: "smoke-token")))
      .build()

    #expect(rain.providerIds.contains(.portal))

    let params = rain.buildTransactionParameters(
      walletAddress: "0x1234567890123456789012345678901234567890",
      contractAddress: "0x9876543210987654321098765432109876543210",
      transactionData: "0x"
    )
    #expect(params.data == "0x")

    #expect(RainSDKError.unauthorized.errorCode == "RAIN_202")
  }

  @Test("resolving an unregistered provider surfaces core's providerNotRegistered")
  func testUnregisteredProviderError() async throws {
    let rain = try RainSdk.builder()
      .rpcEndpoints([NetworkConfig(chainId: 1, rpcUrl: "https://mainnet.example/rpc")])
      .build()

    await #expect(throws: RainSDKError.providerNotRegistered(details: "No provider registered for id 'privy'")) {
      _ = try await rain.provider(.privy)
    }
  }
}
