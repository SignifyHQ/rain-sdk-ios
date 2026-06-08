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

/// Chain family selector, orthogonal to the wallet provider. Solana uses the SDK's sentinel
/// chain IDs (101 mainnet / 102 testnet / 103 devnet) and a Solana JSON-RPC URL.
enum ChainFamily: String, CaseIterable {
  case evm = "EVM"
  case solana = "Solana"

  var displayName: String { rawValue }

  /// Sentinel chain id + RPC prefilled when the family is selected.
  var defaultChainId: String {
    switch self {
    case .evm: return DemoLocalConfig.chainId
    case .solana: return "103" // Solana devnet sentinel
    }
  }

  var defaultRpcUrl: String {
    switch self {
    case .evm: return DemoLocalConfig.rpcUrl
    case .solana: return "https://api.devnet.solana.com"
    }
  }
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

  /// Selected chain family (EVM vs Solana). Changing it prefills chain id + RPC URL.
  @Published var chainFamily: ChainFamily = .evm {
    didSet {
      guard oldValue != chainFamily else { return }
      chainId = chainFamily.defaultChainId
      rpcUrl = chainFamily.defaultRpcUrl
    }
  }

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

  // MARK: - Turnkey Email OTP Inputs

  /// Email the OTP is sent to.
  @Published var turnkeyEmail: String = ""
  /// The code the user types in after receiving the OTP email.
  @Published var turnkeyOtpCode: String = ""
  /// Set once an OTP has been sent; drives the UI from "send" to "verify".
  @Published var turnkeyOtpId: String?
  /// True while an OTP init/verify request is in flight.
  @Published var isProcessingTurnkeyOtp: Bool = false

  /// Encryption target bundle returned by `initOtp`, needed by `completeOtp`.
  private var turnkeyOtpEncryptionTargetBundle: String?

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

  /// Whether the Send OTP button should be enabled. Email OTP runs through the Auth Proxy and
  /// handles login-or-signup, so it needs the same config the passkey signup needs plus an email.
  var canSendEmailOtp: Bool {
    !isProcessingTurnkeyOtp
      && !isAuthenticatingTurnkey
      && turnkeyOtpId == nil
      && !isTrimmedEmpty(turnkeyEmail)
      && !isTrimmedEmpty(turnkeyOrgId)
      && !isTrimmedEmpty(turnkeyApiUrl)
      && !isTrimmedEmpty(turnkeyAuthProxyUrl)
      && !isTrimmedEmpty(turnkeyAuthProxyConfigId)
      && !isTrimmedEmpty(turnkeyRpId)
      && !isTrimmedEmpty(chainId)
      && Int(chainId) != nil
      && !rpcUrl.isEmpty
  }

  /// Whether the Verify OTP button should be enabled.
  var canVerifyEmailOtp: Bool {
    !isProcessingTurnkeyOtp && turnkeyOtpId != nil && !isTrimmedEmpty(turnkeyOtpCode)
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
        createSubOrgParams: try makeWalletSubOrgParams()
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

  // MARK: - Turnkey Email OTP

  /// Start the email-OTP flow: configure Turnkey, then `initOtp`. On success the UI switches
  /// to the verify step (an OTP code field appears).
  func sendTurnkeyEmailOtp() async {
    guard canSendEmailOtp else { return }

    persistTurnkeyConfig()
    isProcessingTurnkeyOtp = true
    sdkService.statusMessage = "Sending OTP..."
    sdkService.error = nil

    do {
      try configureTurnkeyIfNeeded()
      let context = TurnkeyContext.shared
      let result = try await context.initOtp(
        contact: turnkeyEmail.trimmingCharacters(in: .whitespacesAndNewlines),
        otpType: .email
      )
      turnkeyOtpEncryptionTargetBundle = result.otpEncryptionTargetBundle
      turnkeyOtpId = result.otpId
      sdkService.statusMessage = "OTP sent — check your email"
    } catch {
      sdkService.error = .providerError(underlying: error)
      sdkService.statusMessage = "Failed to send OTP"
    }

    isProcessingTurnkeyOtp = false
  }

  /// Verify the OTP code and create a Turnkey session (login or signup, handled by
  /// `completeOtp`), then initialize Rain. Signup provisions a dual-curve (ETH + Solana) wallet.
  func verifyTurnkeyEmailOtp() async {
    guard let chainIdInt = Int(chainId),
          let otpId = turnkeyOtpId,
          let bundle = turnkeyOtpEncryptionTargetBundle,
          canVerifyEmailOtp else { return }

    isProcessingTurnkeyOtp = true
    sdkService.statusMessage = "Verifying OTP..."
    sdkService.error = nil

    do {
      let context = TurnkeyContext.shared
      // Clear any leftover session so re-verifying (e.g. across demo runs) doesn't fail with
      // `keyAlreadyExists` on the default session key.
      context.clearSession(for: TurnkeySwift.Constants.Session.defaultSessionKey)
      _ = try await context.completeOtp(
        otpId: otpId,
        otpCode: turnkeyOtpCode.trimmingCharacters(in: .whitespacesAndNewlines),
        otpEncryptionTargetBundle: bundle,
        contact: turnkeyEmail.trimmingCharacters(in: .whitespacesAndNewlines),
        otpType: .email,
        createSubOrgParams: try makeWalletSubOrgParams(),
        invalidateExisting: true
      )

      await sdkService.initializeTurnkey(
        turnkey: context,
        networkConfigs: makeNetworkConfigs(chainIdInt: chainIdInt)
      )

      // Reset the OTP step on success.
      turnkeyOtpId = nil
      turnkeyOtpCode = ""
      turnkeyOtpEncryptionTargetBundle = nil
    } catch {
      sdkService.error = .providerError(underlying: error)
      sdkService.statusMessage = "OTP verification failed"
    }

    isProcessingTurnkeyOtp = false
  }

  /// Discard an in-progress OTP so the user can restart (e.g. wrong email).
  func cancelTurnkeyEmailOtp() {
    turnkeyOtpId = nil
    turnkeyOtpCode = ""
    turnkeyOtpEncryptionTargetBundle = nil
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

  /// Build `CreateSubOrgParams` carrying a wallet with both an Ethereum and a Solana account,
  /// so the new sub-org can serve EVM (`ADDRESS_FORMAT_ETHEREUM`) and Solana
  /// (`ADDRESS_FORMAT_SOLANA`) chains — matching how Rain's Turnkey adapter resolves the
  /// per-chain address. `CreateSubOrgParams` has no public init, so we go through
  /// `JSONDecoder`. Brittle: if TurnkeySwift changes the field names or shape of
  /// `CreateSubOrgParams`, this fails at runtime during sign-up rather than at compile time.
  /// Revisit if/when TurnkeySwift exposes a public initializer.
  private func makeWalletSubOrgParams() throws -> CreateSubOrgParams {
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
          },
          {
            "addressFormat": "ADDRESS_FORMAT_SOLANA",
            "curve": "CURVE_ED25519",
            "path": "m/44'/501'/0'/0'",
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
