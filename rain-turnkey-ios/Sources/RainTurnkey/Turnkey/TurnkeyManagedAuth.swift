import Combine
import Foundation
import TurnkeySwift
import RainCore

// MARK: - Auth state

/// Where managed Turnkey authentication stands, at the Rain boundary.
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
  /// appears or the state resolves to unauthenticated) or `timeout` elapses.
  internal func awaitSessionRestore(timeout: TimeInterval) async {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if context.session != nil || context.authState == .unAuthenticated { return }
      try? await Task.sleep(nanoseconds: 100_000_000)
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
  /// transparently, then ensures the account has both an Ethereum and a Solana wallet, so a
  /// freshly signed-up user is immediately usable on every chain family Rain serves.
  internal func confirmLoginCode(_ code: String) async throws {
    try throwIfMisconfigured()
    guard let pending = pendingOtpLock.withLock({ pendingOtp }) else {
      throw RainSDKError.invalidConfig(details: "No login code was requested; call sendLoginCode first")
    }
    do {
      // A previous login can leave a stored session; the vendor throws keyAlreadyExists rather
      // than overwriting it.
      context.clearStoredSession()
      try await context.completeOtp(
        otpId: pending.otpId,
        otpCode: code,
        otpEncryptionTargetBundle: pending.encryptionTargetBundle,
        contact: pending.email,
        otpType: .email
      )
      try await ensureWallets()
      pendingOtpLock.withLock { pendingOtp = nil }
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  internal func logout() {
    context.clearStoredSession()
    pendingOtpLock.withLock { pendingOtp = nil }
  }

  // MARK: Wallet provisioning

  /// Ensures the authenticated account has an Ethereum (secp256k1) and a Solana (ed25519)
  /// wallet account. Idempotent: existing accounts are kept.
  private func ensureWallets() async throws {
    try await context.refreshWallets()
    let formats = Set(context.wallets.flatMap(\.accounts).map(\.addressFormat))
    if !formats.contains(.address_format_ethereum) {
      try await context.createTurnkeyWallet(
        walletName: "Wallet",
        accounts: [WalletAccountParams(
          addressFormat: .address_format_ethereum,
          curve: .curve_secp256k1,
          path: "m/44'/60'/0'/0/0",
          pathFormat: .path_format_bip32
        )],
        mnemonicLength: 12
      )
    }
    if !formats.contains(.address_format_solana) {
      try await context.createTurnkeyWallet(
        walletName: "Solana Wallet",
        accounts: [WalletAccountParams(
          addressFormat: .address_format_solana,
          curve: .curve_ed25519,
          path: "m/44'/501'/0'/0'",
          pathFormat: .path_format_bip32
        )],
        mnemonicLength: 12
      )
    }
    try await context.refreshWallets()
  }

  private func throwIfMisconfigured() throws {
    if let configurationError { throw configurationError }
  }
}
