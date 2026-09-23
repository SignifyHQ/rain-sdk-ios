import AuthenticationServices
import Combine
import Foundation
import TurnkeySwift
import TurnkeyTypes
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

// MARK: - Login contact

/// Where a one-time login code is delivered.
/// Not public API — `@_spi(RainWallet)`, surfaced to hosts through RainWallet's neutral enum.
@_spi(RainWallet)
public enum TurnkeyLoginContact: Sendable, Equatable {
  /// Email OTP.
  case email(String)
  /// SMS OTP. Requires SMS auth to be enabled on the wallet backend (Turnkey Enterprise
  /// feature + auth-proxy configuration).
  case phone(String)

  internal var contact: String {
    switch self {
    case .email(let value), .phone(let value): value
    }
  }

  internal var otpType: OtpType {
    switch self {
    case .email: .email
    case .phone: .sms
    }
  }

  /// The contact normalized for the wallet backend: emails are trimmed; phone numbers have
  /// user-visible formatting (spaces, dashes, dots, parentheses) stripped down to E.164.
  /// Throws `invalidConfig` when what remains cannot be a valid contact — a clear local error
  /// beats a wrapped backend rejection. Identical rules on the Android SDK: the normalized
  /// string is the account identity, so both platforms must produce the same one.
  internal func normalized() throws -> TurnkeyLoginContact {
    switch self {
    case .email(let raw):
      let email = raw.trimmingCharacters(in: .whitespacesAndNewlines)
      guard email.contains("@"), email.count >= 3 else {
        throw RainError.invalidConfig(details: "Not a valid email address")
      }
      return .email(email)
    case .phone(let raw):
      let formatting = CharacterSet(charactersIn: "-.()").union(.whitespacesAndNewlines)
      let phone = String(String.UnicodeScalarView(
        raw.unicodeScalars.filter { !formatting.contains($0) }
      ))
      // E.164: a leading "+" and 6–15 digits, nothing else.
      let digits = phone.dropFirst()
      guard phone.hasPrefix("+"),
            (6...15).contains(digits.count),
            digits.allSatisfy({ $0.isASCII && $0.isNumber })
      else {
        throw RainError.invalidConfig(details:
          "Not a valid phone number — use the international format, like +15551234567")
      }
      return .phone(phone)
    }
  }
}

// MARK: - Key export

/// Chain-family selector for a single-key export.
/// Not public API — `@_spi(RainWallet)`, surfaced to hosts through RainWallet's neutral enum.
@_spi(RainWallet)
public enum TurnkeyKeyFamily: Sendable, Equatable {
  /// secp256k1; exports as a 0x-prefixed 32-byte hex string.
  case ethereum
  /// ed25519; exports as plain Base58 of privkey‖pubkey (no checksum), the format Solana wallets import.
  case solana
}

// MARK: - Process-wide configuration

/// Guards `TurnkeyContext.configure(...)`, which is one-shot for the process lifetime.
/// Configuring again with the same values is a no-op; with different values it is an error the
/// caller must surface (the app has to relaunch to change them).
internal enum TurnkeyManagedConfigurator {
  nonisolated(unsafe) private static var configuredWith:
    (organizationId: String, authProxyConfigId: String, rpId: String?)?
  private static let lock = NSLock()

  /// Test seam: replaces the actual vendor configure call.
  nonisolated(unsafe) internal static var configureImpl: @Sendable (String, String, String?) -> Void = { organizationId, authProxyConfigId, rpId in
    TurnkeyContext.configure(
      TurnkeySwift.TurnkeyConfig(
        organizationId: organizationId,
        authProxyConfigId: authProxyConfigId,
        rpId: rpId
      )
    )
  }

  /// Test seam: how a managed provider obtains the process-wide context. The vendor's `.shared`
  /// traps when unconfigured, so tests replace this rather than ever touching the real singleton.
  nonisolated(unsafe) internal static var sharedContext: @Sendable () -> TurnkeyContextProtocol = {
    TurnkeyContext.shared
  }

  /// Configures the Turnkey singleton once per process. Returns the error to surface on every
  /// subsequent call when the ids differ from the ones the process was configured with.
  /// `rpId` is the passkey relying-party domain; `nil` disables passkey flows.
  internal static func configure(
    organizationId: String,
    authProxyConfigId: String,
    rpId: String?
  ) -> RainError? {
    lock.lock(); defer { lock.unlock() }
    if let configuredWith {
      guard configuredWith == (organizationId, authProxyConfigId, rpId) else {
        return .invalidConfig(details:
          "The wallet backend is already configured with different ids for this app launch; "
          + "relaunch the app to change them")
      }
      return nil
    }
    configureImpl(organizationId, authProxyConfigId, rpId)
    configuredWith = (organizationId, authProxyConfigId, rpId)
    return nil
  }
}

// MARK: - Managed auth controller

/// Owns the email-OTP flow for a managed-mode `TurnkeyProvider`: send code, confirm code
/// (signup-or-login), wallet provisioning, logout, and session restore. All vendor errors are
/// mapped to `RainError` before they surface.
internal final class TurnkeyManagedAuthController: @unchecked Sendable {
  private let context: TurnkeyContextProtocol
  /// Set when the process was already configured with different ids; every call fails with it.
  private let configurationError: RainError?

  /// In-flight OTP handed back by `sendLoginCode`, consumed by `confirmLoginCode`.
  private var pendingOtp: (challenge: OtpChallenge, contact: TurnkeyLoginContact)?
  /// In-flight OTP for contact verification (attach a login contact to the current account) —
  /// deliberately separate from `pendingOtp` so a login flow can't consume a verification code.
  private var pendingContactVerification: (challenge: OtpChallenge, contact: TurnkeyLoginContact)?
  private let pendingOtpLock = NSLock()

  /// The passkey relying-party domain from the managed configuration; `nil` means passkeys are
  /// not configured and every passkey call throws `invalidConfig`.
  private let rpId: String?

  /// At swift-sdk 4.0.0 the vendor pins every passkey session to this key — the `sessionKey`
  /// parameters on its passkey flows are accepted but ignored — and refuses to overwrite an
  /// occupied key. See the passkey methods for the resulting session handling.
  internal static let passkeyDefaultSessionKey = "com.turnkey.sdk.session"

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

  internal init(
    context: TurnkeyContextProtocol,
    configurationError: RainError?,
    rpId: String? = nil
  ) {
    self.context = context
    self.configurationError = configurationError
    self.rpId = rpId
  }

  // MARK: State

  internal func currentAuthState() -> TurnkeyAuthState {
    TurnkeyAuthState(context.authState)
  }

  internal var authState: AnyPublisher<TurnkeyAuthState, Never> {
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

  // MARK: One-time-code login (email or SMS)

  internal func sendLoginCode(to contact: TurnkeyLoginContact) async throws {
    try throwIfMisconfigured()
    // The normalized string is the account identity — it is what gets sent, confirmed, and stored.
    let contact = try contact.normalized()
    do {
      let challenge = try await context.sendOtp(
        contact: contact.contact,
        otpType: contact.otpType
      )
      pendingOtpLock.withLock {
        pendingOtp = (challenge, contact)
      }
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  /// Confirms the code from `sendLoginCode`. Handles first-time signup and returning login
  /// transparently, then ensures the account has Ethereum and Solana accounts on a single
  /// wallet seed, so the user is immediately usable on every chain family Rain serves with one
  /// phrase to back up.
  internal func confirmLoginCode(_ code: String) async throws {
    try throwIfMisconfigured()
    guard let pending = pendingOtpLock.withLock({ pendingOtp }) else {
      throw RainError.invalidConfig(details: "No login code was requested; call sendLoginCode first")
    }
    // Log in under a fresh per-attempt session key: the vendor throws keyAlreadyExists only for
    // a same-key collision, so an already-active session survives a mistyped code (verifyOtp
    // consumes the code, so a premature logout could not be undone by retrying). Mirrors the
    // Android SDK's behaviour.
    let attemptKey = "rain-turnkey-\(UUID().uuidString)"
    let previousKey = context.selectedStoredSessionKey
    do {
      try await context.completeOtp(
        otpId: pending.challenge.otpId,
        otpCode: code,
        otpEncryptionTargetBundle: pending.challenge.encryptionTargetBundle,
        contact: pending.contact.contact,
        otpType: pending.contact.otpType,
        sessionKey: attemptKey,
        // Signup creates ONE wallet with both accounts atomically; ignored on login.
        signupWalletAccounts: [Self.ethereumAccount, Self.solanaAccount]
      )
    } catch {
      // Nothing was stored or cleared — a live session stays live and the user can request a
      // new code.
      throw RainError.from(underlying: error)
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
      throw RainError.from(underlying: error)
    }
    // The previous session is superseded; drop it so per-attempt keys don't accumulate.
    if let previousKey, previousKey != attemptKey {
      context.clearStoredSession(sessionKey: previousKey)
    }
    do {
      try await ensureWallets()
      pendingOtpLock.withLock { pendingOtp = nil }
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  // MARK: Passkeys

  /// Signs an existing user in with a passkey. Provisioning is re-checked afterwards (backfill
  /// for accounts predating one-seed provisioning).
  internal func loginWithPasskey(anchor: ASPresentationAnchor) async throws {
    try throwIfMisconfigured()
    try requirePasskeysConfigured()
    try await refuseIfLivePasskeySession()
    let previousKey = context.selectedStoredSessionKey
    preparePasskeyDefaultKey()
    do {
      try await context.loginWithTurnkeyPasskey(anchor: anchor)
    } catch {
      // Nothing was stored or cleared beyond a stale unselected key — a live session stays live.
      throw RainError.from(underlying: error)
    }
    try await activatePasskeySession(previousKey: previousKey)
    do {
      try await ensureWallets()
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  /// Creates a NEW account with a passkey — one wallet with both chain-family accounts is
  /// provisioned atomically inside the signup. Returning users must use `loginWithPasskey`
  /// (or a login code): every call here mints a fresh account with an empty wallet.
  internal func signUpWithPasskey(anchor: ASPresentationAnchor) async throws {
    try throwIfMisconfigured()
    try requirePasskeysConfigured()
    try await refuseIfLivePasskeySession()
    let previousKey = context.selectedStoredSessionKey
    preparePasskeyDefaultKey()
    do {
      try await context.signUpWithTurnkeyPasskey(
        anchor: anchor,
        signupWalletAccounts: [Self.ethereumAccount, Self.solanaAccount]
      )
    } catch {
      throw RainError.from(underlying: error)
    }
    try await activatePasskeySession(previousKey: previousKey)
    do {
      try await ensureWallets()
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  /// Registers a passkey on the CURRENT account (active session required), so the user can sign
  /// in with it later. No new account, no session change.
  internal func addPasskey(anchor: ASPresentationAnchor) async throws {
    try throwIfMisconfigured()
    try requirePasskeysConfigured()
    do {
      try await context.addPasskeyAuthenticator(anchor: anchor, rpId: rpId ?? "")
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  @discardableResult
  private func requirePasskeysConfigured() throws -> String {
    guard let rpId, !rpId.isEmpty else {
      throw RainError.invalidConfig(details:
        "Passkeys are not configured for this app: the relying-party domain is missing. "
        + "The app also needs the Associated Domains entitlement for that domain.")
    }
    return rpId
  }

  /// The vendor refuses to store a passkey session over an occupied default key — and it does so
  /// as the LAST step of the ceremony (4.0.0: createPasskey → proxySignup → stampLogin →
  /// storeSession). Over a live passkey session that would mint a keychain passkey (and, for
  /// signup, a whole Turnkey account) only to fail. We know the outcome up front, so refuse
  /// before Face ID and before any network call. `invalidConfig` is a state error here, not a
  /// configuration one, but no closer code exists and a new one would fork the cross-platform
  /// map. An EXPIRED session still parked under the selected default key protects nothing and
  /// would also block the store, so it is purged instead and the ceremony proceeds.
  private func refuseIfLivePasskeySession() async throws {
    guard context.selectedStoredSessionKey == Self.passkeyDefaultSessionKey,
          context.session != nil else { return }
    if hasActiveSession() {
      throw RainError.invalidConfig(details: "Already signed in with a passkey; log out first")
    }
    context.clearStoredSession(sessionKey: Self.passkeyDefaultSessionKey)
    // Clearing the SELECTED key flips the vendor's live state from a main-actor Task. Let it
    // settle before the ceremony so the fresh session is auto-selected, not wiped by a late flip.
    await awaitSessionTeardown()
  }

  /// The vendor refuses to store a passkey session over an occupied default key. Purge a stale
  /// stored session under it — but NEVER the live selection, so a cancelled or failed ceremony
  /// cannot log anyone out (a live passkey session is refused earlier, see
  /// `refuseIfLivePasskeySession`).
  private func preparePasskeyDefaultKey() {
    if context.selectedStoredSessionKey != Self.passkeyDefaultSessionKey {
      context.clearStoredSession(sessionKey: Self.passkeyDefaultSessionKey)
    }
  }

  /// Mirrors the OTP flow's activation: the vendor auto-selects only when nothing was selected,
  /// so over a live session the fresh passkey session (always under the default key) is
  /// activated explicitly, then the superseded key is purged.
  private func activatePasskeySession(previousKey: String?) async throws {
    do {
      if context.selectedStoredSessionKey != Self.passkeyDefaultSessionKey {
        try await context.selectStoredSession(sessionKey: Self.passkeyDefaultSessionKey)
      }
    } catch {
      // Don't leave the never-selected passkey session orphaned in the keychain.
      context.clearStoredSession(sessionKey: Self.passkeyDefaultSessionKey)
      throw RainError.from(underlying: error)
    }
    if let previousKey, previousKey != Self.passkeyDefaultSessionKey {
      context.clearStoredSession(sessionKey: previousKey)
    }
  }

  // MARK: Contact verification (attach a login contact to the current account)

  /// Sends a verification code to a contact the user wants to ATTACH to the current account
  /// (active session required). Distinct from `sendLoginCode`, which starts a login.
  internal func sendContactVerificationCode(to contact: TurnkeyLoginContact) async throws {
    try throwIfMisconfigured()
    guard hasActiveSession() else { throw RainError.tokenExpired }
    // Normalized before it is verified and attached — the stored contact must be the exact
    // string a later login normalizes to.
    let contact = try contact.normalized()
    do {
      let challenge = try await context.sendOtp(
        contact: contact.contact,
        otpType: contact.otpType
      )
      pendingOtpLock.withLock {
        pendingContactVerification = (challenge, contact)
      }
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  /// Confirms the code from `sendContactVerificationCode` and attaches the contact — VERIFIED,
  /// so it becomes a login method for this account. A wrong code throws `invalidLoginCode` and
  /// keeps the challenge, so the user can retype it.
  internal func confirmContactVerification(_ code: String) async throws {
    try throwIfMisconfigured()
    guard let pending = pendingOtpLock.withLock({ pendingContactVerification }) else {
      throw RainError.invalidConfig(details:
        "No verification code was requested; call sendContactVerificationCode first")
    }
    do {
      let token = try await context.verifyOtpToken(
        otpId: pending.challenge.otpId,
        otpCode: code,
        otpEncryptionTargetBundle: pending.challenge.encryptionTargetBundle
      )
      switch pending.contact {
      case .email(let email):
        try await context.setUserEmail(email, verificationToken: token)
      case .phone(let phone):
        try await context.setUserPhoneNumber(phone, verificationToken: token)
      }
      pendingOtpLock.withLock { pendingContactVerification = nil }
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  internal func logout() async {
    context.clearStoredSession(sessionKey: nil) // nil = the currently selected session
    pendingOtpLock.withLock {
      pendingOtp = nil
      pendingContactVerification = nil
    }
    // The vendor wipes storage synchronously but flips `session` / `authState` from a main-actor
    // Task slightly later. Wait (bounded) for the live state to settle so callers can read
    // `authState` / `hasActiveSession()` immediately after logout returns.
    await awaitSessionTeardown()
  }

  /// Bounded wait for the vendor's asynchronous live-state flip after the selected session was
  /// cleared.
  private func awaitSessionTeardown() async {
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

  // MARK: Key export

  /// Exports the wallet's 12-word mnemonic phrase, decrypted on-device. One wallet seed per
  /// account (see `ensureWallets`), so a single phrase restores every chain family.
  /// The SDK never logs or persists the value; display and gating are the host's responsibility.
  internal func exportMnemonic() async throws -> String {
    try throwIfMisconfigured()
    do {
      let wallet = try await requireWallet()
      return try await context.exportWalletMnemonic(walletId: wallet.walletId)
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  /// Exports one account's private key, decrypted on-device: Ethereum as a 0x-prefixed 32-byte
  /// hex string (the form Ethereum wallets import), Solana as plain Base58 of privkey‖pubkey —
  /// formats shared with the Android SDK.
  /// The SDK never logs or persists the value; display and gating are the host's responsibility.
  internal func exportPrivateKey(family: TurnkeyKeyFamily) async throws -> String {
    try throwIfMisconfigured()
    do {
      _ = try await requireWallet()
      let format: v1AddressFormat =
        family == .ethereum ? .address_format_ethereum : .address_format_solana
      guard let account = context.wallets.flatMap(\.accounts).first(where: { $0.addressFormat == format })
      else {
        // Login provisions both families (ensureWallets); reaching this means provisioning was
        // interrupted — a re-login repairs it.
        throw RainError.internalError(
          details: "No \(family) account exists to export; log in again to provision it")
      }
      let value = try await context.exportAccountPrivateKey(
        address: account.address,
        encoding: family == .ethereum ? .hexSecp256k1 : .solanaBase58
      )
      // The decrypted secp256k1 key is bare hex; the 0x prefix is the Rain-boundary format.
      return family == .ethereum ? "0x" + value : value
    } catch {
      throw RainError.from(underlying: error)
    }
  }

  /// The account's wallet, refreshing the cached list once if it is empty. Post one-seed
  /// provisioning there is exactly one; legacy accounts can still hold several wallets (several
  /// seeds), so anchor on the wallet carrying the Ethereum account in use — the exported phrase
  /// must derive the same address as the exported Ethereum key.
  private func requireWallet() async throws -> Wallet {
    if context.wallets.isEmpty {
      try await context.refreshWallets()
    }
    let wallets = context.wallets
    let ethereumWallet = wallets.first { wallet in
      wallet.accounts.contains { $0.addressFormat == .address_format_ethereum }
    }
    guard let wallet = ethereumWallet ?? wallets.first else {
      throw TurnkeySwiftError.invalidSession
    }
    return wallet
  }

  private func throwIfMisconfigured() throws {
    if let configurationError { throw configurationError }
  }
}
