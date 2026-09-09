import Testing
import Foundation
import TurnkeySwift
import TurnkeyTypes
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

  // MARK: - Key export

  @Test("export methods delegate to the backend with the right account and encoding")
  func testExportDelegation() async throws {
    // Built around the public init: the process-wide configurator is one-shot, so a second
    // provider with fresh ids would carry a configurationError and fail every call. The internal
    // seams inject the stub directly instead.
    let stub = StubBackendContext()
    stub.wallets = [Self.dualAccountWallet()]
    let provider = RainProvider(backing: TurnkeyProvider(
      config: TurnkeyConfig(organizationId: "org", authProxyConfigId: "auth"),
      context: stub,
      managedAuth: TurnkeyManagedAuthController(context: stub, configurationError: nil)
    ))

    let phrase = try await provider.exportRecoveryPhrase()
    let ethKey = try await provider.exportPrivateKey(.ethereum)
    let solKey = try await provider.exportPrivateKey(.solana)

    #expect(phrase == stub.stubbedMnemonic)
    #expect(ethKey == "0x" + stub.stubbedExportedKey) // Ethereum keys are 0x-prefixed
    #expect(solKey == stub.stubbedExportedKey)
    #expect(stub.exportMnemonicCalls == ["wallet-id"])
    #expect(stub.exportKeyCalls == [
      .init(address: "0xeth-address", encoding: .hexSecp256k1),
      .init(address: "sol-address", encoding: .solanaBase58),
    ])
  }

  /// `Wallet` has no public memberwise init — round-trip through its Codable conformance.
  private static func dualAccountWallet() -> Wallet {
    struct WalletFixture: Encodable {
      let walletId: String
      let walletName: String
      let createdAt: String
      let updatedAt: String
      let exported: Bool
      let imported: Bool
      let accounts: [WalletAccount]
    }
    func account(address: String, format: v1AddressFormat, curve: v1Curve, path: String) -> WalletAccount {
      WalletAccount(
        address: address,
        addressFormat: format,
        createdAt: externaldatav1Timestamp(nanos: "0", seconds: "0"),
        curve: curve,
        organizationId: "org-id",
        path: path,
        pathFormat: .path_format_bip32,
        publicKey: nil,
        updatedAt: externaldatav1Timestamp(nanos: "0", seconds: "0"),
        walletAccountId: "wallet-account-id-\(address)",
        walletDetails: nil,
        walletId: "wallet-id"
      )
    }
    let fixture = WalletFixture(
      walletId: "wallet-id", walletName: "wallet", createdAt: "0", updatedAt: "0",
      exported: false, imported: false,
      accounts: [
        account(
          address: "0xeth-address", format: .address_format_ethereum,
          curve: .curve_secp256k1, path: "m/44'/60'/0'/0/0"
        ),
        account(
          address: "sol-address", format: .address_format_solana,
          curve: .curve_ed25519, path: "m/44'/501'/0'/0'"
        ),
      ]
    )
    let data = try! JSONEncoder().encode(fixture)
    return try! JSONDecoder().decode(Wallet.self, from: data)
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
