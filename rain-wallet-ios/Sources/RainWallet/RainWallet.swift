// RainWallet — the Rain-branded wallet provider.
//
// Rain issues each partner an organization id and an auth configuration id; authentication
// (email one-time codes) runs inside the SDK, and the resolved `RainClient` exposes the same
// wallet surface as every other provider.
//
//     import RainWallet   // surfaces RainCore too
//
//     let provider = RainProvider(
//         RainWalletConfig(organizationId: "<org-id>", authConfigId: "<auth-config-id>")
//     )
//
//     await provider.awaitSessionRestore()
//     if !provider.hasActiveSession() {
//         try await provider.sendLoginCode(email: "user@example.com")
//         try await provider.confirmLoginCode(code)
//     }
//
//     let rain = try RainSdk.builder()
//         .rpcEndpoints([43114: "https://…"])
//         .register(provider)
//         .build()
//     let client = try await rain.provider(.rain)

import Combine
import Foundation
@_exported import RainCore
// SPI: Turnkey's managed-auth surface is @_spi(RainWallet) — this module is its only consumer.
// `internal` keeps the compiler-enforced guarantee that no Turnkey type leaks into our public API.
@_spi(RainWallet) internal import RainTurnkey

// MARK: - Auth state

/// Where Rain wallet authentication stands.
public enum RainWalletAuthState: Sendable, Equatable {
  /// The SDK is still restoring a possible previous session from secure storage.
  case loading
  /// A session is active; the provider can be resolved and wallet calls will succeed.
  case authenticated
  /// No session; run `sendLoginCode` / `confirmLoginCode`.
  case unauthenticated

  internal init(_ state: TurnkeyAuthState) {
    switch state {
    case .loading: self = .loading
    case .authenticated: self = .authenticated
    case .unauthenticated: self = .unauthenticated
    }
  }
}

// MARK: - Session state

/// The wallet session as seen at the SDK boundary. Observable via ``RainProvider/sessionState``
/// so a host can react to a session dying without waiting for a wallet call to fail.
public enum RainWalletSessionState: Sendable, Equatable {
  /// The SDK is still restoring persisted sessions (app launch).
  case loading
  /// A session exists and has not expired.
  case active(expiresAt: TimeInterval)
  /// The session has expired. Re-authenticate.
  case expired
  /// No session (never logged in, logged out, or expired out).
  case unauthenticated

  internal init(_ state: TurnkeySessionState) {
    switch state {
    case .loading: self = .loading
    case .active(let expiresAt): self = .active(expiresAt: expiresAt)
    case .expired: self = .expired
    case .unauthenticated: self = .unauthenticated
    }
  }
}

// MARK: - Session policy

/// Session-hardening policy for the Rain wallet provider.
///
/// Controls how the SDK guards wallet calls against session expiry and transient failures:
/// expiry is checked before every backend call, sessions inside `refreshBufferSeconds` of expiry
/// are refreshed proactively (when `autoRefresh` is on), an invalid-session failure is refreshed
/// and retried once, and transient failures on read paths are retried with exponential backoff.
/// Writes (sends, signing) are never retried on transient failures.
public struct RainWalletSessionPolicy: Sendable {
  /// Refresh the session when it is within this window of expiring.
  public var refreshBufferSeconds: TimeInterval
  /// When true the SDK refreshes the session itself; when false an expired session surfaces as
  /// `RainSDKError.tokenExpired` and re-auth is the host's job.
  public var autoRefresh: Bool
  /// TTL (in seconds, as a string) requested for refreshed sessions; `nil` uses the backend
  /// default (900 seconds).
  public var refreshExpirationSeconds: String?
  /// Retries (beyond the first attempt) for transient failures on idempotent reads.
  public var maxTransientRetries: Int
  /// First backoff delay; doubles per retry up to `maxRetryDelay`.
  public var initialRetryDelay: TimeInterval
  /// Backoff ceiling.
  public var maxRetryDelay: TimeInterval

  public init(
    refreshBufferSeconds: TimeInterval = 60,
    autoRefresh: Bool = true,
    refreshExpirationSeconds: String? = nil,
    maxTransientRetries: Int = 2,
    initialRetryDelay: TimeInterval = 0.5,
    maxRetryDelay: TimeInterval = 4
  ) {
    self.refreshBufferSeconds = refreshBufferSeconds
    self.autoRefresh = autoRefresh
    self.refreshExpirationSeconds = refreshExpirationSeconds
    self.maxTransientRetries = maxTransientRetries
    self.initialRetryDelay = initialRetryDelay
    self.maxRetryDelay = maxRetryDelay
  }

  internal var backingPolicy: TurnkeySessionPolicy {
    TurnkeySessionPolicy(
      refreshBufferSeconds: refreshBufferSeconds,
      autoRefresh: autoRefresh,
      refreshExpirationSeconds: refreshExpirationSeconds,
      maxTransientRetries: maxTransientRetries,
      initialRetryDelay: initialRetryDelay,
      maxRetryDelay: maxRetryDelay
    )
  }
}

// MARK: - Configuration

/// Configuration for the Rain wallet provider. Rain issues the `organizationId` and
/// `authConfigId` to each partner.
public struct RainWalletConfig: Sendable {
  /// The wallet organization id issued by Rain.
  public let organizationId: String
  /// The authentication configuration id issued by Rain.
  public let authConfigId: String
  /// Optional explicit EVM wallet address. When `nil`, the first Ethereum account is used.
  public let walletAddress: String?
  /// Expiry/refresh/retry behavior for the session guarding every wallet call.
  public let sessionPolicy: RainWalletSessionPolicy
  /// Re-auth hook: invoked once per session death when the session dies and cannot be refreshed.
  /// Not necessarily on the main thread; hop to the main actor before touching UI, and never
  /// call back into the SDK synchronously from it. Restart authentication from here
  /// (`sendLoginCode` / `confirmLoginCode`).
  public let onSessionExpired: (@Sendable () -> Void)?

  public init(
    organizationId: String,
    authConfigId: String,
    walletAddress: String? = nil,
    sessionPolicy: RainWalletSessionPolicy = RainWalletSessionPolicy(),
    onSessionExpired: (@Sendable () -> Void)? = nil
  ) {
    self.organizationId = organizationId
    self.authConfigId = authConfigId
    self.walletAddress = walletAddress
    self.sessionPolicy = sessionPolicy
    self.onSessionExpired = onSessionExpired
  }
}

// MARK: - Provider

/// Registrable descriptor for the Rain wallet provider.
///
/// The SDK owns authentication: send a one-time login code to the user's email, confirm it
/// (first-time signup and returning login are handled transparently, and the account's EVM and
/// Solana wallets are provisioned automatically), then register the provider and resolve
/// `rain.provider(.rain)`.
///
/// The underlying wallet-backend configuration is one-shot per app launch — constructing a second
/// provider with *different* ids makes every auth call on it throw `invalidConfig` until the app
/// relaunches. The Rain wallet provider cannot be registered alongside the Turnkey provider.
public struct RainProvider: ProviderDescriptor {
  private let backing: TurnkeyProvider

  public init(_ config: RainWalletConfig) {
    self.backing = TurnkeyProvider(
      TurnkeyConfig(
        organizationId: config.organizationId,
        authProxyConfigId: config.authConfigId,
        walletAddress: config.walletAddress,
        sessionPolicy: config.sessionPolicy.backingPolicy,
        onSessionExpired: config.onSessionExpired
      )
    )
  }

  public var id: ProviderId { .rain }

  public var capabilities: Set<Capability> { [.multiChain, .biometricGate] }

  public func create(context: ProviderContext) async throws -> any WalletProvider {
    try await backing.create(context: context)
  }

  // MARK: Authentication (email one-time codes)

  /// Where authentication stands. `.unauthenticated` in a fresh install; `.authenticated` once a
  /// session is live (restored, or established via the login-code flow).
  public var authState: RainWalletAuthState {
    RainWalletAuthState(backing.authState)
  }

  /// `authState` over time. Emits on every auth change; finishes never.
  public var authStates: AnyPublisher<RainWalletAuthState, Never> {
    backing.authStates.map(RainWalletAuthState.init).removeDuplicates().eraseToAnyPublisher()
  }

  /// Sends a one-time login code to `email`.
  public func sendLoginCode(email: String) async throws {
    try await backing.sendLoginCode(email: email)
  }

  /// Confirms the code from ``sendLoginCode(email:)``, signing the user up on first login, and
  /// provisions the account's EVM and Solana wallets.
  public func confirmLoginCode(_ code: String) async throws {
    try await backing.confirmLoginCode(code)
  }

  /// Clears the stored session (full logout). Safe no-op when none exists.
  public func logout() throws {
    try backing.logout()
  }

  /// Waits for the asynchronous session restore that follows configuration, so a returning
  /// user's session can be reused without re-running the login-code flow.
  public func awaitSessionRestore(timeout: TimeInterval = 5) async {
    await backing.awaitSessionRestore(timeout: timeout)
  }

  /// True when an unexpired session is already loaded and the login-code flow can be skipped.
  public func hasActiveSession() -> Bool {
    backing.hasActiveSession()
  }

  // MARK: Session

  /// The wallet session over time. Emits on every auth/session change and when an active session
  /// passes its expiry.
  public var sessionState: AnyPublisher<RainWalletSessionState, Never> {
    backing.sessionState.map(RainWalletSessionState.init).eraseToAnyPublisher()
  }

  /// Snapshot of ``sessionState`` right now.
  public func currentSessionState() -> RainWalletSessionState {
    RainWalletSessionState(backing.currentSessionState())
  }

  /// Forces a session refresh (extended expiry) regardless of remaining lifetime. Throws
  /// `RainSDKError.tokenExpired` when the session cannot be refreshed — re-authenticate.
  public func refreshSession() async throws {
    try await backing.refreshSession()
  }

  /// Stops the passive session watcher. Call when discarding this provider (e.g. rebuilding the
  /// SDK for a new login) so a stale provider can never fire its expiry hook again.
  public func close() {
    backing.close()
  }
}
