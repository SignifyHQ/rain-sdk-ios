import Combine
import Foundation
import TurnkeySwift
import RainCore

// MARK: - Auth state

/// Where managed Turnkey authentication stands, at the Rain boundary.
/// Not public API — `@_spi(RainWallet)`, surfaced to hosts only through `RainWalletAuthState`.
@_spi(RainWallet)
public enum TurnkeyAuthState: Sendable, Equatable {
  /// The SDK is still restoring a possible previous session from secure storage.
  case loading
  /// A session is active; the provider can be resolved and wallet calls will succeed.
  case authenticated
  /// No session; run `sendLoginCode` / `confirmLoginCode`.
  case unauthenticated

  internal init(_ vendorState: AuthState) {
    switch vendorState {
    case .authenticated: self = .authenticated
    case .unAuthenticated: self = .unauthenticated
    default: self = .loading
    }
  }
}

// MARK: - Process-wide configuration

/// Guards `TurnkeyContext.configure(...)`, which is one-shot for the process lifetime.
/// Configuring again with the same values is a no-op; with different values it is an error the
/// caller must surface (the app has to relaunch to change them).
internal enum TurnkeyManagedConfigurator {
  nonisolated(unsafe) private static var configuredWith: (organizationId: String, authProxyConfigId: String)?
  private static let lock = NSLock()

  /// Test seam: replaces the actual vendor configure call.
  nonisolated(unsafe) internal static var configureImpl: @Sendable (String, String) -> Void = { organizationId, authProxyConfigId in
    TurnkeyContext.configure(
      TurnkeySwift.TurnkeyConfig(organizationId: organizationId, authProxyConfigId: authProxyConfigId)
    )
  }

  /// Test seam: how a managed provider obtains the process-wide context. The vendor's `.shared`
  /// traps when unconfigured, so tests replace this rather than ever touching the real singleton.
  nonisolated(unsafe) internal static var sharedContext: @Sendable () -> TurnkeyContextProtocol = {
    TurnkeyContext.shared
  }

  /// Configures the Turnkey singleton once per process. Returns the error to surface on every
  /// subsequent call when the ids differ from the ones the process was configured with.
  internal static func configure(organizationId: String, authProxyConfigId: String) -> RainSDKError? {
    lock.lock(); defer { lock.unlock() }
    if let configuredWith {
      guard configuredWith == (organizationId, authProxyConfigId) else {
        return .invalidConfig(details:
          "The wallet backend is already configured with different ids for this app launch; "
          + "relaunch the app to change them")
      }
      return nil
    }
    configureImpl(organizationId, authProxyConfigId)
    configuredWith = (organizationId, authProxyConfigId)
    return nil
  }
}

// MARK: - Managed auth controller

/// Owns the email-OTP flow for a managed-mode `TurnkeyProvider`: send code, confirm code
/// (signup-or-login), wallet provisioning, logout, and session restore. All vendor errors are
/// mapped to `RainSDKError` before they surface.
internal final class TurnkeyManagedAuthController: @unchecked Sendable {
  private let context: TurnkeyContextProtocol
  /// Set when the process was already configured with different ids; every call fails with it.
  private let configurationError: RainSDKError?

  /// In-flight OTP handed back by `sendLoginCode`, consumed by `confirmLoginCode`.
  private var pendingOtp: (otpId: String, encryptionTargetBundle: String, email: String)?
  private let pendingOtpLock = NSLock()

  /// Minimum remaining lifetime (seconds) for a restored session to count as active.
  private static let sessionMinRemainingSeconds: TimeInterval = 30

  /// The account set every Rain user gets, derived from ONE wallet seed (standard first-index
  /// derivation paths). A single seed per user is a cross-platform contract with the Android SDK:
  /// one phrase to back up and export, regardless of chain family.
  internal static let ethereumAccount = WalletAccountParams(
    addressFormat: .address_format_ethereum,
    curve: .curve_secp256k1,
    path: "m/44'/60'/0'/0/0",
    pathFormat: .path_format_bip32
  )
  internal static let solanaAccount = WalletAccountParams(
    addressFormat: .address_format_solana,
    curve: .curve_ed25519,
    path: "m/44'/501'/0'/0'",
    pathFormat: .path_format_bip32
  )

  internal init(context: TurnkeyContextProtocol, configurationError: RainSDKError?) {
    self.context = context
    self.configurationError = configurationError
  }

  // MARK: State

  internal var authState: TurnkeyAuthState {
    TurnkeyAuthState(context.authState)
  }

  internal var authStates: AnyPublisher<TurnkeyAuthState, Never> {
    context.authStatePublisher.map(TurnkeyAuthState.init).removeDuplicates().eraseToAnyPublisher()
  }

  /// True when an unexpired session is already loaded (restored from secure storage), so the
  /// OTP flow can be skipped.
  internal func hasActiveSession() -> Bool {
    guard let session = context.session else { return false }
    return session.exp > Date().timeIntervalSince1970 + Self.sessionMinRemainingSeconds
  }

  /// The session restore after configuration is asynchronous; waits until it settles (a session
  /// appears or the state resolves to unauthenticated) or `timeout` elapses. A restored session
  /// also gets wallet provisioning re-checked (see below).
  internal func awaitSessionRestore(timeout: TimeInterval) async {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if context.session != nil || context.authState == .unAuthenticated { break }
      try? await Task.sleep(nanoseconds: 100_000_000)
    }
    // A previous login can have died between session storage and wallet provisioning (e.g. a
    // network blip in ensureWallets after completeOtp succeeded): the session is live, the host
    // skips the OTP flow, and confirmLoginCode — the only other place provisioning runs — never
    // executes again, stranding the account without one of its chain families. Re-check here,
    // best-effort: a failure simply retries on the next restore, and the check is a no-op when
    // both accounts exist.
    if hasActiveSession() {
      try? await ensureWallets()
    }
  }

  // MARK: Email OTP

  internal func sendLoginCode(email: String) async throws {
    try throwIfMisconfigured()
    do {
      let challenge = try await context.sendOtp(contact: email, otpType: .email)
      pendingOtpLock.withLock {
        pendingOtp = (challenge.otpId, challenge.encryptionTargetBundle, email)
      }
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  /// Confirms the code from `sendLoginCode`. Handles first-time signup and returning login
  /// transparently, then ensures the account has Ethereum and Solana accounts on a single
  /// wallet seed, so the user is immediately usable on every chain family Rain serves with one
  /// phrase to back up.
  internal func confirmLoginCode(_ code: String) async throws {
    try throwIfMisconfigured()
    guard let pending = pendingOtpLock.withLock({ pendingOtp }) else {
      throw RainSDKError.invalidConfig(details: "No login code was requested; call sendLoginCode first")
    }
    // Log in under a fresh per-attempt session key: the vendor throws keyAlreadyExists only for
    // a same-key collision, so an already-active session survives a mistyped code (verifyOtp
    // consumes the code, so a premature logout could not be undone by retrying). Mirrors the
    // Android SDK's behaviour.
    let attemptKey = "rain-turnkey-\(UUID().uuidString)"
    let previousKey = context.selectedStoredSessionKey
    do {
      try await context.completeOtp(
        otpId: pending.otpId,
        otpCode: code,
        otpEncryptionTargetBundle: pending.encryptionTargetBundle,
        contact: pending.email,
        otpType: .email,
        sessionKey: attemptKey,
        // Signup creates ONE wallet with both accounts atomically; ignored on login.
        signupWalletAccounts: [Self.ethereumAccount, Self.solanaAccount]
      )
    } catch {
      // Nothing was stored or cleared — a live session stays live and the user can request a
      // new code.
      throw RainSDKError.from(underlying: error)
    }
    do {
      // The vendor auto-selects the new session only when none was selected; over a live
      // session the attempt key must be activated explicitly.
      if context.selectedStoredSessionKey != attemptKey {
        try await context.selectStoredSession(sessionKey: attemptKey)
      }
    } catch {
      // Don't leave the never-selected attempt session orphaned in the keychain.
      context.clearStoredSession(sessionKey: attemptKey)
      throw RainSDKError.from(underlying: error)
    }
    // The previous session is superseded; drop it so per-attempt keys don't accumulate.
    if let previousKey, previousKey != attemptKey {
      context.clearStoredSession(sessionKey: previousKey)
    }
    do {
      try await ensureWallets()
      pendingOtpLock.withLock { pendingOtp = nil }
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  internal func logout() async {
    context.clearStoredSession(sessionKey: nil) // nil = the currently selected session
    pendingOtpLock.withLock { pendingOtp = nil }
    // The vendor wipes storage synchronously but flips `session` / `authState` from a main-actor
    // Task slightly later. Wait (bounded) for the live state to settle so callers can read
    // `authState` / `hasActiveSession()` immediately after logout returns.
    let deadline = Date().addingTimeInterval(2)
    while Date() < deadline {
      if context.session == nil && context.authState == .unAuthenticated { return }
      try? await Task.sleep(nanoseconds: 20_000_000)
    }
  }

  // MARK: Wallet provisioning

  /// Ensures the authenticated account has an Ethereum (secp256k1) and a Solana (ed25519)
  /// account, on ONE wallet seed. Fresh signups already get both atomically (see
  /// `signupWalletAccounts` on `completeOtp`); this backfills accounts that predate that, by
  /// deriving the missing account(s) from the existing wallet's seed — never by creating a
  /// second wallet. Idempotent: existing accounts are kept.
  private func ensureWallets() async throws {
    try await context.refreshWallets()
    guard let wallet = context.wallets.first else {
      // No wallet at all (an account created outside this flow): one wallet, both accounts.
      try await context.createTurnkeyWallet(
        walletName: "Wallet",
        accounts: [Self.ethereumAccount, Self.solanaAccount],
        mnemonicLength: 12
      )
      return
    }
    let formats = Set(context.wallets.flatMap(\.accounts).map(\.addressFormat))
    var missing: [WalletAccountParams] = []
    if !formats.contains(.address_format_ethereum) { missing.append(Self.ethereumAccount) }
    if !formats.contains(.address_format_solana) { missing.append(Self.solanaAccount) }
    guard !missing.isEmpty else { return }
    try await context.addAccountsToTurnkeyWallet(walletId: wallet.walletId, accounts: missing)
  }

  private func throwIfMisconfigured() throws {
    if let configurationError { throw configurationError }
  }
}
