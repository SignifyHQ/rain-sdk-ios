import Foundation
import RainCore
import RainPortal
import RainPrivy
import PortalSwift
import PrivySDK
import TurnkeySwift

/// App-side holder around the modular SDK.
///
/// The demo picks a provider at runtime (Portal, Turnkey, or Privy), so it builds the ``RainSdk``
/// lazily once the user supplies credentials and then keeps the resolved ``RainClient`` here.
/// Screens read `rain` / `client` directly — there is no wrapper layer over the SDK surface.
/// Setup failures the demo can explain better than the vendor error can.
enum PortalWalletSetupError: LocalizedError {
  case walletNotOnThisDevice

  var errorDescription: String? {
    switch self {
    case .walletNotOnThisDevice:
      return "This Portal client already has a wallet, but its signing share is not on this "
        + "device. Recover it from a backup, or use a client ID dedicated to this device."
    }
  }
}

@MainActor
final class RainSDKService: ObservableObject {
  static let shared = RainSDKService()

  enum ActiveProvider {
    case none
    case portal
    case turnkey
    case privy
  }

  /// The built SDK registry (Rain API + wallet-agnostic building). Nil before initialization.
  private(set) var rain: RainSdk?

  /// The provider-backed client (address, balances, send, withdraw). Nil before initialization.
  private(set) var client: RainClient?

  /// Holds the `Portal` for provider-only APIs (wallet generation, backup/recover). Boxed because
  /// the hook fires synchronously off the main actor — an actor hop would land too late.
  private final class PortalBox: @unchecked Sendable {
    var value: Portal?
  }

  private let portalBox = PortalBox()

  @Published private(set) var isInitialized = false

  /// Provider behind the last successful initialize; used to gate provider-specific UI.
  @Published private(set) var activeProvider: ActiveProvider = .none

  /// Network the feature screens operate on, selected via the home-screen dropdown.
  @Published var selectedChain: WalletChain = .avalancheFuji

  // Rain API credentials entered on the home screen. Stashed here because the SDK is built
  // lazily — applied via the builder at build time and pushed through configureRainApi when
  // the SDK already exists.
  private var rainApiKey = ""
  private var rainUserId = ""

  private init() {}

  /// True once an Api-Key and userId are available (SDK built or not).
  var isRainApiConfigured: Bool {
    rain?.isRainApiConfigured ?? (!rainApiKey.isEmpty && !rainUserId.isEmpty)
  }

  /// Stores the Rain Api-Key + userId and forwards them to the SDK when it exists.
  func configureRainApi(apiKey: String, userId: String) {
    rainApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    rainUserId = userId.trimmingCharacters(in: .whitespacesAndNewlines)
    rain?.configureRainApi(apiKey: rainApiKey, userId: rainUserId)
  }

  /// Builds the SDK with the Portal provider and resolves the Portal-backed client.
  /// Portal holds no Solana account, so it is initialized with the EVM chains only.
  func initializePortal(sessionToken: String) async throws {
    RainLogger.isEnabled = true
    let sdk = try builder(networkConfigs: WalletChain.evmNetworkConfigs)
      .register(
        PortalProvider(PortalConfig(sessionToken: sessionToken)) { [portalBox] portal in
          portalBox.value = portal
        }
      )
      .build()
    try await resolve(sdk: sdk, providerId: .portal, provider: .portal)
  }

  /// Ensures this device can sign for the Portal client, running MPC key generation on first
  /// use. Returns true if a wallet was created, false if one was already usable here.
  ///
  /// A newly-provisioned Portal client has no wallet, and nothing in the Rain surface creates
  /// one — every address lookup would fail with `walletUnavailable` until this runs.
  @discardableResult
  func ensurePortalWallet() async throws -> Bool {
    guard let portal = portalBox.value else { throw RainSDKError.sdkNotInitialized }

    // Two independent facts: the signing share lives in this device's keychain, the wallet
    // itself lives on the Portal client. Creating on a client that already has one fails.
    let onDevice = try await portal.isWalletOnDevice()
    let onClient = try await portal.doesWalletExist()
    SampleLog.d("Portal.wallet", "ensurePortalWallet onDevice=\(onDevice) onClient=\(onClient)")

    if onDevice { return false }
    if onClient { throw PortalWalletSetupError.walletNotOnThisDevice }

    let created = try await portal.createWallet { status in
      SampleLog.d("Portal.wallet", "keygen status=\(status.status)")
    }
    SampleLog.i("Portal.wallet", "created wallet eth=\(created.ethereum)")
    return true
  }

  /// Builds the SDK with the Turnkey provider and resolves the Turnkey-backed client.
  func initializeTurnkey(turnkey: TurnkeyContext, walletAddress: String? = nil) async throws {
    RainLogger.isEnabled = true
    let sdk = try builder(networkConfigs: WalletChain.networkConfigs)
      .register(TurnkeyProvider(TurnkeyConfig(turnkey: turnkey, walletAddress: walletAddress)))
      .build()
    try await resolve(sdk: sdk, providerId: .turnkey, provider: .turnkey)
  }

  /// Builds the SDK with the Privy provider and resolves the Privy-backed client.
  func initializePrivy(privy: any Privy, walletAddress: String? = nil) async throws {
    RainLogger.isEnabled = true
    let sdk = try builder(networkConfigs: WalletChain.networkConfigs)
      .register(PrivyProvider(PrivyConfig(privy: privy, walletAddress: walletAddress)))
      .build()
    try await resolve(sdk: sdk, providerId: .privy, provider: .privy)
  }

  /// The built registry, or throws `sdkNotInitialized` if no `initialize*` has run.
  func requireRain() throws -> RainSdk {
    guard let rain else { throw RainSDKError.sdkNotInitialized }
    return rain
  }

  /// The resolved provider client, or throws `sdkNotInitialized` before initialization.
  func requireClient() throws -> RainClient {
    guard let client else { throw RainSDKError.sdkNotInitialized }
    return client
  }

  /// Drops the built registry and resolved client.
  func reset() {
    client?.reset()
    rain?.reset()
    rain = nil
    client = nil
    portalBox.value = nil
    isInitialized = false
    activeProvider = .none
  }

  // MARK: - Building

  /// Shared builder setup: RPC endpoints, the Rain API credentials, and token naming.
  ///
  /// An SPL mint carries no on-chain symbol (and Turnkey's asset index skips devnet), while on
  /// EVM the built-in registry is mainnet-only — so the testnet tokens this demo expects are
  /// registered here, the same mechanism host apps use.
  private func builder(networkConfigs: [NetworkConfig]) -> RainSdk.Builder {
    let builder = RainSdk.builder()
      .rpcEndpoints(networkConfigs)
      .registerTokens(WalletChain.allCases.map(\.defaultTokenInfo))
    if !rainApiKey.isEmpty && !rainUserId.isEmpty {
      builder.rainApiCredentials(apiKey: rainApiKey, userId: rainUserId)
    }
    return builder
  }

  private func resolve(sdk: RainSdk, providerId: ProviderId, provider: ActiveProvider) async throws {
    let resolved = try await sdk.provider(providerId)
    rain = sdk
    client = resolved
    isInitialized = resolved.isInitialized
    activeProvider = provider
  }
}
