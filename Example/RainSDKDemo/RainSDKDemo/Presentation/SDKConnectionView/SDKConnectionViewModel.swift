import Foundation
import RainSDK
import Combine
import AuthenticationServices
import TurnkeySwift

/// Wallet provider option when not in wallet-agnostic mode.
enum WalletProviderOption: String, CaseIterable {
  case portal = "Portal"
  case turnkey = "Turnkey"

  var displayName: String { rawValue }
}

/// ViewModel for SDK Connection View
/// Handles business logic and state management for SDK initialization
@MainActor
class SDKConnectionViewModel: ObservableObject {
  // MARK: - Dependencies

  private let sdkService: RainSDKService

  // MARK: - Published Properties

  /// Portal session token input
  @Published var sessionToken: String = ""

  /// RPC URL input
  @Published var rpcUrl: String = DemoLocalConfig.rpcUrl

  /// Chain ID input
  @Published var chainId: String = DemoLocalConfig.chainId

  /// Initialization mode: true for wallet-agnostic, false for Portal (or other provider)
  @Published var useWalletAgnostic: Bool = false

  /// Selected wallet provider when not wallet-agnostic
  @Published var selectedProvider: WalletProviderOption = .portal

  /// Initialization loading state
  @Published var isInitializing: Bool = false

  /// SDK initialization state (from service)
  @Published var isInitialized: Bool = false

  /// Current error state (from service)
  @Published var error: RainSDKError?

  /// Status message (from service)
  @Published var statusMessage: String = "Not initialized"

  // MARK: - Turnkey Inputs

  @Published var turnkeyOrgId: String = ""
  @Published var turnkeyApiUrl: String = TurnkeyConfigStorage.defaultApiUrl
  @Published var turnkeyAuthProxyUrl: String = TurnkeyConfigStorage.defaultAuthProxyUrl
  @Published var turnkeyAuthProxyConfigId: String = ""
  @Published var turnkeyRpId: String = ""

  /// True while a passkey authentication request is in flight.
  @Published var isAuthenticatingTurnkey: Bool = false

  /// One-time Turnkey configuration. `TurnkeyContext.configure(...)` must be called before
  /// the first `.shared` access; we defer it until the user taps a passkey button so the
  /// user has a chance to enter org id / rpId / etc. first.
  private static var turnkeyConfigured = false

  /// Snapshot of the values passed to `TurnkeyContext.configure(...)`. Used to detect
  /// when the user has edited org/rpId/etc. after configure was called — in that case
  /// we surface a clear error rather than silently using the stale config.
  private static var configuredSnapshot: (orgId: String, apiUrl: String, authProxyUrl: String, authProxyConfigId: String?, rpId: String)?

  // MARK: - Computed Properties

  /// Check if initialize button should be enabled
  var canInitialize: Bool {
    guard !isInitializing else { return false }
    guard !rpcUrl.isEmpty, !chainId.isEmpty, Int(chainId) != nil else { return false }

    if useWalletAgnostic { return true }

    switch selectedProvider {
    case .portal:
      return !sessionToken.isEmpty
    case .turnkey:
      // Turnkey has its own auth buttons (Login/Sign up with Passkey); the main
      // Initialize button is hidden in that flow.
      return false
    }
  }

  /// Whether the Login with Passkey button should be enabled.
  var canAuthenticateWithPasskey: Bool {
    !isAuthenticatingTurnkey
      && !isTrimmedEmpty(turnkeyOrgId)
      && !isTrimmedEmpty(turnkeyApiUrl)
      && !isTrimmedEmpty(turnkeyAuthProxyUrl)
      && !isTrimmedEmpty(turnkeyRpId)
      && !isTrimmedEmpty(chainId)
      && Int(chainId) != nil
      && !rpcUrl.isEmpty
  }

  /// Whether the Sign Up with Passkey button should be enabled.
  /// Signup creates a fresh sub-org under the parent org and additionally requires the auth proxy config id.
  var canSignUpWithPasskey: Bool {
    canAuthenticateWithPasskey && !isTrimmedEmpty(turnkeyAuthProxyConfigId)
  }

  // MARK: - Initialization

  init(sdkService: RainSDKService = .shared) {
    self.sdkService = sdkService
    self.sessionToken = PortalTokenStorage.getToken() ?? ""
    self.turnkeyOrgId = TurnkeyConfigStorage.organizationId
    self.turnkeyApiUrl = TurnkeyConfigStorage.apiUrl
    self.turnkeyAuthProxyUrl = TurnkeyConfigStorage.authProxyUrl
    self.turnkeyAuthProxyConfigId = TurnkeyConfigStorage.authProxyConfigId
    self.turnkeyRpId = TurnkeyConfigStorage.rpId

    // Observe service state changes
    observeServiceState()
  }

  // MARK: - Service State Observation

  private func observeServiceState() {
    // Observe isInitialized
    sdkService.$isInitialized
      .assign(to: &$isInitialized)

    // Observe error
    sdkService.$error
      .assign(to: &$error)

    // Observe statusMessage
    sdkService.$statusMessage
      .assign(to: &$statusMessage)
  }

  // MARK: - Actions

  /// Initialize the SDK with current input values (wallet-agnostic or Portal).
  /// Turnkey runs through `loginWithPasskey` / `signUpWithPasskey` instead.
  func initializeSDK() async {
    guard let chainIdInt = Int(chainId) else {
      return
    }

    isInitializing = true

    let networkConfigs = makeNetworkConfigs(chainIdInt: chainIdInt)

    if useWalletAgnostic {
      await sdkService.initializeWalletAgnostic(networkConfigs: networkConfigs)
    } else if selectedProvider == .portal {
      PortalTokenStorage.saveToken(sessionToken)
      await sdkService.initialize(
        portalToken: sessionToken,
        networkConfigs: networkConfigs
      )
    }

    isInitializing = false
  }

  /// Reset the SDK state. Does not unset `turnkeyConfigured` because
  /// `TurnkeyContext.configure(...)` is one-shot for the process lifetime; the next
  /// passkey attempt will detect config drift and tell the user to relaunch.
  func resetSDK() {
    sdkService.reset()
  }

  // MARK: - Turnkey Passkey

  /// Sign in to Turnkey with an existing passkey, then initialize Rain.
  func loginWithTurnkeyPasskey(anchor: ASPresentationAnchor) async {
    guard let chainIdInt = Int(chainId), canAuthenticateWithPasskey else { return }

    persistTurnkeyConfig()
    isAuthenticatingTurnkey = true
    sdkService.statusMessage = "Authenticating with passkey..."
    sdkService.error = nil

    do {
      try configureTurnkeyIfNeeded()
      let context = TurnkeyContext.shared
      // Clear any leftover session from a previous login so the next call
      // doesn't fail with `keyAlreadyExists` on the default session key.
      // Clear by default key — `clearSession()` no-args is a no-op on fresh launch
      // (selectedSessionKey is nil while the Keychain still holds a prior JWT).
      context.clearSession(for: TurnkeySwift.Constants.Session.defaultSessionKey)
      _ = try await context.loginWithPasskey(anchor: anchor)

      await sdkService.initializeTurnkey(
        turnkey: context,
        networkConfigs: makeNetworkConfigs(chainIdInt: chainIdInt)
      )
    } catch {
      sdkService.error = .providerError(underlying: error)
      sdkService.statusMessage = "Turnkey passkey login failed"
    }

    isAuthenticatingTurnkey = false
  }

  /// Create a fresh Turnkey sub-org (with a wallet, per the auth proxy's defaults) and
  /// register a passkey for it on the device. Then initialize Rain.
  func signUpWithTurnkeyPasskey(anchor: ASPresentationAnchor) async {
    guard let chainIdInt = Int(chainId), canSignUpWithPasskey else { return }

    persistTurnkeyConfig()
    isAuthenticatingTurnkey = true
    sdkService.statusMessage = "Registering passkey..."
    sdkService.error = nil

    do {
      try configureTurnkeyIfNeeded()
      let context = TurnkeyContext.shared
      // Clear by default key — `clearSession()` no-args is a no-op on fresh launch
      // (selectedSessionKey is nil while the Keychain still holds a prior JWT).
      context.clearSession(for: TurnkeySwift.Constants.Session.defaultSessionKey)
      _ = try await context.signUpWithPasskey(
        anchor: anchor,
        createSubOrgParams: try makeEthereumWalletSubOrgParams()
      )

      await sdkService.initializeTurnkey(
        turnkey: context,
        networkConfigs: makeNetworkConfigs(chainIdInt: chainIdInt)
      )
    } catch {
      sdkService.error = .providerError(underlying: error)
      sdkService.statusMessage = "Turnkey passkey signup failed"
    }

    isAuthenticatingTurnkey = false
  }

  // MARK: - Turnkey Configuration

  private func configureTurnkeyIfNeeded() throws {
    let orgId = turnkeyOrgId.trimmingCharacters(in: .whitespacesAndNewlines)
    let apiUrl = turnkeyApiUrl.trimmingCharacters(in: .whitespacesAndNewlines)
    let authProxyUrl = turnkeyAuthProxyUrl.trimmingCharacters(in: .whitespacesAndNewlines)
    let authProxyConfigId = turnkeyAuthProxyConfigId.trimmingCharacters(in: .whitespacesAndNewlines)
    let rpId = turnkeyRpId.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !orgId.isEmpty, !apiUrl.isEmpty, !authProxyUrl.isEmpty, !rpId.isEmpty else {
      throw NSError(
        domain: "RainSDKDemo.Turnkey", code: -2,
        userInfo: [NSLocalizedDescriptionKey: "Missing Turnkey configuration."])
    }

    let snapshot = (
      orgId: orgId,
      apiUrl: apiUrl,
      authProxyUrl: authProxyUrl,
      authProxyConfigId: authProxyConfigId.isEmpty ? nil : authProxyConfigId,
      rpId: rpId
    )

    if Self.turnkeyConfigured {
      // `TurnkeyContext.configure(...)` is one-shot for the process lifetime. If the
      // user edits a config field after the first configure, fail loudly instead of
      // silently using stale values.
      if let existing = Self.configuredSnapshot, existing != snapshot {
        throw NSError(
          domain: "RainSDKDemo.Turnkey", code: -4,
          userInfo: [NSLocalizedDescriptionKey:
            "Turnkey is already configured with different values this session. Fully kill the app and relaunch to apply changes to Organization ID, API URL, Auth Proxy URL, Auth Proxy Config ID, or rpId."])
      }
      return
    }

    TurnkeyContext.configure(
      TurnkeyConfig(
        organizationId: orgId,
        apiUrl: apiUrl,
        authProxyUrl: authProxyUrl,
        authProxyConfigId: snapshot.authProxyConfigId,
        rpId: rpId
      )
    )
    Self.turnkeyConfigured = true
    Self.configuredSnapshot = snapshot
  }

  private func persistTurnkeyConfig() {
    TurnkeyConfigStorage.organizationId = turnkeyOrgId
    TurnkeyConfigStorage.apiUrl = turnkeyApiUrl
    TurnkeyConfigStorage.authProxyUrl = turnkeyAuthProxyUrl
    TurnkeyConfigStorage.authProxyConfigId = turnkeyAuthProxyConfigId
    TurnkeyConfigStorage.rpId = turnkeyRpId
  }

  /// Build `CreateSubOrgParams` carrying a default Ethereum wallet so the new sub-org
  /// always has a wallet whose first account uses `ADDRESS_FORMAT_ETHEREUM` (which is
  /// what Rain's Turnkey adapter resolves to). `CreateSubOrgParams` has no public init,
  /// so we go through `JSONDecoder`. Brittle: if TurnkeySwift changes the field names
  /// or shape of `CreateSubOrgParams`, this fails at runtime during sign-up rather
  /// than at compile time. Revisit if/when TurnkeySwift exposes a public initializer.
  private func makeEthereumWalletSubOrgParams() throws -> CreateSubOrgParams {
    let json = """
    {
      "customWallet": {
        "walletName": "Rain Demo Wallet",
        "accounts": [
          {
            "addressFormat": "ADDRESS_FORMAT_ETHEREUM",
            "curve": "CURVE_SECP256K1",
            "path": "m/44'/60'/0'/0/0",
            "pathFormat": "PATH_FORMAT_BIP32"
          }
        ]
      }
    }
    """
    guard let data = json.data(using: .utf8) else {
      throw NSError(
        domain: "RainSDKDemo.Turnkey", code: -3,
        userInfo: [NSLocalizedDescriptionKey: "Failed to encode wallet params."])
    }
    return try JSONDecoder().decode(CreateSubOrgParams.self, from: data)
  }

  private func makeNetworkConfigs(chainIdInt: Int) -> [NetworkConfig] {
    [
      NetworkConfig(
        chainId: chainIdInt,
        rpcUrl: rpcUrl,
        networkName: "Demo Network"
      )
    ]
  }

  private func isTrimmedEmpty(_ value: String) -> Bool {
    value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  // MARK: - Future Feature Actions

  /// Handle Portal wallet features action
  /// TODO: Implement Portal wallet features
  func handlePortalWalletFeatures() {
    // Future implementation
  }

  /// Handle collateral withdrawal action
  /// TODO: Implement collateral withdrawal
  func handleCollateralWithdrawal() {
    // Future implementation
  }

  /// Handle fee estimation action
  /// TODO: Implement fee estimation
  func handleFeeEstimation() {
    // Future implementation
  }
}
