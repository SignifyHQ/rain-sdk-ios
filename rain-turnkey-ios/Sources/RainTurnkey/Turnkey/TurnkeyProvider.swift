import Combine
import Foundation
import TurnkeySwift
@_spi(RainAdapter) import RainCore

/// Configuration for the Turnkey provider.
///
/// Public mode is **bring-your-own** (`init(turnkey:...)`): the host drives Turnkey's Swift SDK
/// (passkeys / auth proxy / OAuth / OTP) and hands the authenticated `TurnkeyContext` to Rain;
/// the SDK never touches authentication.
///
/// A second, **managed** mode (`init(organizationId:authProxyConfigId:...)`, where the SDK owns
/// the email-OTP flow) exists behind `@_spi(RainWallet)` and ships to hosts only through the
/// `RainWallet` module.
///
/// `@unchecked Sendable`: `TurnkeyContext` is a reference type with mutable published state that
/// Rain reads from arbitrary executors. BYO host contract: finish authentication before handing
/// the context to Rain, and don't mutate it (re-auth, logout, wallet switch) while Rain calls are
/// in flight — after such changes, build a new `RainSdk` / re-resolve the provider.
public struct TurnkeyConfig: @unchecked Sendable {
  internal enum Mode: @unchecked Sendable {
    /// Host-authenticated context; the SDK exposes no auth surface.
    case byoContext(TurnkeyContext)
    /// SDK-managed auth against the Turnkey organization + auth-proxy configuration.
    case managed(organizationId: String, authProxyConfigId: String)
  }

  internal let mode: Mode
  /// Optional explicit EVM wallet address. When `nil`, Rain uses the first Ethereum account from
  /// the Turnkey context.
  public let walletAddress: String?
  /// Expiry/refresh/retry behavior for the session guarding every wallet call.
  public let sessionPolicy: TurnkeySessionPolicy
  /// Re-auth hook: invoked once per session death when the Turnkey session dies and cannot be
  /// refreshed — whether that is discovered during a wallet call or by the passive session
  /// watcher. Not necessarily on the main thread; hop to the main actor before touching UI,
  /// and never call back into the SDK synchronously from it. Restart authentication from here
  /// (in managed mode: `sendLoginCode` / `confirmLoginCode` again).
  public let onSessionExpired: (@Sendable () -> Void)?

  /// Bring-your-own mode: `turnkey` is an already-authenticated Turnkey context.
  public init(
    turnkey: TurnkeyContext,
    walletAddress: String? = nil,
    sessionPolicy: TurnkeySessionPolicy = TurnkeySessionPolicy(),
    onSessionExpired: (@Sendable () -> Void)? = nil
  ) {
    self.mode = .byoContext(turnkey)
    self.walletAddress = walletAddress
    self.sessionPolicy = sessionPolicy
    self.onSessionExpired = onSessionExpired
  }

  /// Managed mode: the SDK configures Turnkey against this organization + auth-proxy
  /// configuration and owns the email-OTP authentication flow.
  ///
  /// Not public API. `@_spi(RainWallet)`: managed auth ships exclusively through the
  /// `RainWallet` module's `RainProvider` — the public Turnkey provider is bring-your-own,
  /// where the host owns authentication.
  ///
  /// The underlying Turnkey configuration is one-shot per app launch — constructing a second
  /// managed provider with *different* ids leaves the first configuration in place and makes
  /// every auth call on the new provider throw `invalidConfig`.
  ///
  /// Single active login per user: `confirmLoginCode` completes the OTP with Turnkey's
  /// `invalidateExisting: true`, which server-side kills every other login session the user has —
  /// including on other devices. Logging in on a second phone therefore logs the first one out
  /// (its next call fails, firing `onSessionExpired` there). A cross-platform contract with the
  /// Android SDK, which passes the same value.
  @_spi(RainWallet)
  public init(
    organizationId: String,
    authProxyConfigId: String,
    walletAddress: String? = nil,
    sessionPolicy: TurnkeySessionPolicy = TurnkeySessionPolicy(),
    onSessionExpired: (@Sendable () -> Void)? = nil
  ) {
    self.mode = .managed(organizationId: organizationId, authProxyConfigId: authProxyConfigId)
    self.walletAddress = walletAddress
    self.sessionPolicy = sessionPolicy
    self.onSessionExpired = onSessionExpired
  }
}

/// Registrable descriptor for the Turnkey wallet provider.
///
/// Turnkey is bundled inside `RainCore` for now (it will graduate to a standalone `rain-turnkey`
/// module later). It implements `ProviderDescriptor` like any adapter, but relies on the core-internal
/// `ProviderContext` EVM chain reader that out-of-core adapters cannot reach yet — that must be
/// widened when the module is extracted.
///
/// ```swift
/// let rain = try RainSdk.builder()
///     .rpcEndpoints([43114: "https://…"])
///     .register(TurnkeyProvider(TurnkeyConfig(turnkey: turnkeyContext)))
///     .build()
/// let client = try await rain.provider(.turnkey)
/// ```
/// `@unchecked Sendable`: `context` is the Turnkey context (a reference type with mutable
/// published state — the same value `TurnkeyConfig` already carries under `@unchecked`), and the
/// coordinator / managed-auth controller are internally synchronized classes. The provider itself
/// is immutable after init.
public struct TurnkeyProvider: ProviderDescriptor, @unchecked Sendable {
  private let config: TurnkeyConfig
  private let coordinator: TurnkeySessionCoordinator
  private let context: TurnkeyContextProtocol
  /// Present in managed mode only; owns the email-OTP flow.
  private let managedAuth: TurnkeyManagedAuthController?

  public init(_ config: TurnkeyConfig) {
    // Turnkey vendor errors classify via core's extensible mapper (like Portal / Privy);
    // registering here guarantees the mapper is live before any Turnkey-backed call can fail —
    // including managed-auth calls, which happen before any wallet is resolved.
    TurnkeyErrorMapping.registerOnce()

    let context: TurnkeyContextProtocol
    let managedAuth: TurnkeyManagedAuthController?
    switch config.mode {
    case .byoContext(let turnkey):
      context = turnkey
      managedAuth = nil
    case .managed(let organizationId, let authProxyConfigId):
      // One-shot per process; a mismatch is remembered and thrown from every auth call.
      let configurationError = TurnkeyManagedConfigurator.configure(
        organizationId: organizationId,
        authProxyConfigId: authProxyConfigId
      )
      let shared = TurnkeyManagedConfigurator.sharedContext()
      context = shared
      managedAuth = TurnkeyManagedAuthController(context: shared, configurationError: configurationError)
    }

    self.init(config: config, context: context, managedAuth: managedAuth)
  }

  /// Test seam: injects the context (and managed-auth controller) directly.
  internal init(
    config: TurnkeyConfig,
    context: TurnkeyContextProtocol,
    managedAuth: TurnkeyManagedAuthController?
  ) {
    self.config = config
    self.context = context
    self.managedAuth = managedAuth
    self.coordinator = TurnkeySessionCoordinator(
      turnkey: context,
      policy: config.sessionPolicy,
      onSessionExpired: config.onSessionExpired
    )
  }

  public var id: ProviderId { .turnkey }

  public var capabilities: Set<Capability> { [.multiChain, .biometricGate] }

  /// The Turnkey session as seen at the Rain boundary, over time. Emits on every Turnkey
  /// auth/session change and when an active session passes its expiry, so a host can react to
  /// a session dying silently without waiting for a wallet call to fail.
  public var sessionState: AnyPublisher<TurnkeySessionState, Never> {
    coordinator.sessionStates
  }

  /// Snapshot of `sessionState` right now.
  public func currentSessionState() -> TurnkeySessionState {
    coordinator.currentState()
  }

  /// Forces a Turnkey session refresh (new JWT, extended expiry) regardless of remaining
  /// lifetime. Throws `RainSDKError.tokenExpired` when the session cannot be refreshed — the
  /// host must re-authenticate.
  public func refreshSession() async throws {
    try await coordinator.refreshNow()
  }

  /// Stops the passive session watcher. Call when discarding this provider (e.g. rebuilding
  /// the SDK for a new login) so a stale provider stops observing the process-wide Turnkey
  /// singleton and can never fire its expiry hook again.
  public func close() {
    coordinator.stopMonitoring()
  }

  public func create(context: ProviderContext) async throws -> any WalletProvider {
    // The watcher only exists to drive the host's re-auth hook; without one there is nothing
    // to notify and no reason to hold a subscription on the Turnkey singleton.
    if config.onSessionExpired != nil {
      coordinator.startMonitoring()
    }

    let provider = TurnkeyWalletProviderAdapter(
      turnkey: self.context, // the Turnkey context — `context` alone is the ProviderContext parameter
      networkConfigs: context.networkConfigs,
      walletAddress: config.walletAddress,
      chainReader: context.evmChainReader,
      solanaSupport: context.solanaSupport,
      tokenStore: context.tokenStore,
      sessionCoordinator: coordinator
    )
    // Probe the wallet so an unusable context fails fast at resolution time (parity with the
    // old initializeTurnkey behaviour). In managed mode this is also what surfaces "resolved
    // before authentication finished" as a clean error.
    _ = try await provider.address()
    return provider
  }
}

// MARK: - Managed authentication (email OTP)

// Not public API. `@_spi(RainWallet)`: this entire surface exists for the `RainWallet` module,
// which wraps a managed provider under wallet-neutral names. The public Turnkey provider is
// bring-your-own — the host authenticates with Turnkey's SDK itself and hands in the context.
extension TurnkeyProvider {
  /// Where managed authentication stands. `.unauthenticated` in a fresh install;
  /// `.authenticated` once a session is live (restored, or established via the OTP flow).
  /// Always `.unauthenticated`-shaped in BYO mode — the host owns auth there.
  @_spi(RainWallet)
  public var authState: TurnkeyAuthState {
    managedAuth?.authState ?? .unauthenticated
  }

  /// `authState` over time. Emits on every auth change; finishes never.
  @_spi(RainWallet)
  public var authStates: AnyPublisher<TurnkeyAuthState, Never> {
    managedAuth?.authStates ?? Just(.unauthenticated).eraseToAnyPublisher()
  }

  /// Sends a one-time login code to `email`. Managed mode only.
  @_spi(RainWallet)
  public func sendLoginCode(email: String) async throws {
    try await requireManagedAuth().sendLoginCode(email: email)
  }

  /// Confirms the code from ``sendLoginCode(email:)``, signing the user up on first login, and
  /// ensures the account has Ethereum and Solana accounts on one wallet seed. Managed mode only.
  /// Throws `RainSDKError.invalidLoginCode` when the code is rejected (wrong, expired, or already
  /// used) — re-prompt the user rather than restarting the flow.
  @_spi(RainWallet)
  public func confirmLoginCode(_ code: String) async throws {
    try await requireManagedAuth().confirmLoginCode(code)
  }

  /// Clears the stored session (full logout). Safe no-op when none exists. Managed mode only —
  /// throws `invalidConfig` in BYO mode, where the host owns the session.
  ///
  /// Async because the vendor flips the live auth state from a main-actor Task after wiping
  /// storage: the call returns only once `authState` / `hasActiveSession()` reflect the logout.
  @_spi(RainWallet)
  public func logout() async throws {
    try await requireManagedAuth().logout()
  }

  /// Waits for the asynchronous session restore that follows configuration, so a returning
  /// user's session can be reused without re-running the OTP flow. No-op in BYO mode.
  @_spi(RainWallet)
  public func awaitSessionRestore(timeout: TimeInterval = 5) async {
    await managedAuth?.awaitSessionRestore(timeout: timeout)
  }

  /// True when an unexpired session is already loaded and the OTP flow can be skipped.
  @_spi(RainWallet)
  public func hasActiveSession() -> Bool {
    managedAuth?.hasActiveSession() ?? false
  }

  private func requireManagedAuth() throws -> TurnkeyManagedAuthController {
    guard let managedAuth else {
      throw RainSDKError.invalidConfig(details:
        "Authentication methods are only available in managed mode — construct the provider with "
        + "TurnkeyConfig(organizationId:authProxyConfigId:); in bring-your-own mode the host owns "
        + "authentication")
    }
    return managedAuth
  }
}
