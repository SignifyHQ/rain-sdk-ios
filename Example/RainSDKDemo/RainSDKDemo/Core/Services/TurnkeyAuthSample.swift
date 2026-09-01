import Foundation
import TurnkeySwift

/// Sample-app glue that drives Turnkey's Swift SDK end-to-end (configure, email OTP, wallet
/// provisioning) so the host app can hand a ready `TurnkeyContext` to
/// `RainSDKService.initializeTurnkey(turnkey:)`.
///
/// This file is NOT part of Rain SDK. It is reference code a host app would write itself — Rain
/// SDK intentionally does not own Turnkey auth. Copy / adapt for your own app.
@MainActor
enum TurnkeyAuthSample {
  /// Hand this to `RainSDKService.initializeTurnkey(turnkey:)` once auth is complete.
  static var context: TurnkeyContext { TurnkeyContext.shared }

  /// Sub-organization ID minted (or reused) for the authenticated user. Nil before login.
  static var subOrganizationId: String? { TurnkeyContext.shared.session?.organizationId }

  /// Minimum session lifetime (seconds) still worth resuming.
  private static let sessionMinRemainingSeconds: TimeInterval = 30

  /// `TurnkeyContext.configure(...)` is one-shot for the process lifetime, so the values it was
  /// called with are snapshotted to detect edits made afterwards.
  private static var configuredWith: (organizationId: String, authProxyConfigId: String)?

  /// Configures the Turnkey singleton. Idempotent; editing the ids afterwards throws, because
  /// Turnkey cannot be reconfigured without relaunching the app.
  static func configure(organizationId: String, authProxyConfigId: String) throws {
    let snapshot = (organizationId: organizationId, authProxyConfigId: authProxyConfigId)
    if let configuredWith {
      guard configuredWith == snapshot else {
        throw NSError(
          domain: "RainSDKDemo.Turnkey", code: -1,
          userInfo: [NSLocalizedDescriptionKey:
            "Turnkey is already configured with different values this session. Fully kill the app "
            + "and relaunch to change the Organization ID or Auth Proxy Config ID."])
      }
      return
    }
    SampleLog.d(
      "TurnkeyAuth",
      "configure org=\(SampleLog.maskToken(organizationId)) proxy=\(SampleLog.maskToken(authProxyConfigId))"
    )
    TurnkeyContext.configure(
      TurnkeyConfig(organizationId: organizationId, authProxyConfigId: authProxyConfigId)
    )
    configuredWith = snapshot
    _ = TurnkeyContext.shared
  }

  /// `TurnkeyContext` restores the Keychain session asynchronously after configure; wait for it.
  static func awaitSessionRestore(timeout: TimeInterval = 5) async {
    guard configuredWith != nil else { return }
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if TurnkeyContext.shared.session != nil || TurnkeyContext.shared.authState == .unAuthenticated { return }
      try? await Task.sleep(nanoseconds: 100_000_000)
    }
  }

  /// True when an authenticated, unexpired session is already loaded. Turnkey restores a
  /// previously-selected session from the Keychain, so this reports whether the OTP step can be
  /// skipped entirely.
  static func hasActiveSession() -> Bool {
    guard let session = TurnkeyContext.shared.session else { return false }
    return session.exp > Date().timeIntervalSince1970 + sessionMinRemainingSeconds
  }

  /// Email of the user a restored session belongs to, or nil if it cannot be determined. Callers
  /// reusing a restored session MUST compare this against the email being logged in — a valid
  /// session for a *different* email must not be reused.
  static func activeSessionEmail() async -> String? {
    guard hasActiveSession() else { return nil }
    if let email = TurnkeyContext.shared.user?.userEmail { return email }
    do {
      try await TurnkeyContext.shared.refreshUser()
    } catch {
      SampleLog.w("TurnkeyAuth", "refreshUser failed while resolving session owner: \(error)")
      return nil
    }
    return TurnkeyContext.shared.user?.userEmail
  }

  /// Clears the stored session (full logout). Safe no-op when none exists.
  static func logout() {
    guard configuredWith != nil else { return }
    TurnkeyContext.shared.clearSession(for: TurnkeySwift.Constants.Session.defaultSessionKey)
  }

  /// Starts the email-OTP flow. The returned `otpId` and `otpEncryptionTargetBundle` are both
  /// needed by ``verifyEmailOtp(otpId:otpCode:otpEncryptionTargetBundle:email:)``.
  static func sendEmailOtp(email: String) async throws -> InitOtpResult {
    SampleLog.d("TurnkeyAuth", "sendEmailOtp to=\(SampleLog.maskEmail(email))")
    let result = try await TurnkeyContext.shared.initOtp(contact: email, otpType: .email)
    SampleLog.d("TurnkeyAuth", "OTP sent otpId=\(SampleLog.maskToken(result.otpId))")
    return result
  }

  /// Verifies the OTP code and creates a session. `completeOtp` handles first-time signup and
  /// returning login transparently.
  static func verifyEmailOtp(
    otpId: String,
    otpCode: String,
    otpEncryptionTargetBundle: String,
    email: String
  ) async throws {
    SampleLog.d("TurnkeyAuth", "verifyEmailOtp otpId=\(SampleLog.maskToken(otpId))")
    // A prior login leaves a session under the default key; Turnkey throws `keyAlreadyExists`
    // rather than overwriting it, so clear it first.
    TurnkeyContext.shared.clearSession(for: TurnkeySwift.Constants.Session.defaultSessionKey)
    _ = try await TurnkeyContext.shared.completeOtp(
      otpId: otpId,
      otpCode: otpCode,
      otpEncryptionTargetBundle: otpEncryptionTargetBundle,
      contact: email,
      otpType: .email,
      invalidateExisting: true
    )
    SampleLog.d("TurnkeyAuth", "session active subOrgId=\(SampleLog.maskToken(subOrganizationId))")
  }

  /// Ensures the authenticated sub-org has an Ethereum-format account (secp256k1). Returns true
  /// when a new wallet was created.
  static func ensureEthereumWallet() async throws -> Bool {
    try await ensureWallet(
      addressFormat: .address_format_ethereum,
      curve: .curve_secp256k1,
      path: "m/44'/60'/0'/0/0",
      walletName: "Rain SDK Sample Wallet"
    )
  }

  /// Ensures the authenticated sub-org has a Solana-format account (ed25519), so the demo can
  /// hand Rain both an EVM and a Solana account. Returns true when a new wallet was created.
  static func ensureSolanaWallet() async throws -> Bool {
    try await ensureWallet(
      addressFormat: .address_format_solana,
      curve: .curve_ed25519,
      path: "m/44'/501'/0'/0'",
      walletName: "Rain SDK Sample Solana Wallet"
    )
  }

  private static func ensureWallet(
    addressFormat: AddressFormat,
    curve: Curve,
    path: String,
    walletName: String
  ) async throws -> Bool {
    try await TurnkeyContext.shared.refreshWallets()
    let hasAccount = TurnkeyContext.shared.wallets
      .flatMap(\.accounts)
      .contains { $0.addressFormat == addressFormat }
    SampleLog.d(
      "TurnkeyAuth",
      "ensureWallet \(addressFormat.rawValue) wallets=\(TurnkeyContext.shared.wallets.count) has=\(hasAccount)"
    )
    if hasAccount { return false }

    try await TurnkeyContext.shared.createWallet(
      walletName: walletName,
      accounts: [
        WalletAccountParams(
          addressFormat: addressFormat,
          curve: curve,
          path: path,
          pathFormat: .path_format_bip32
        )
      ],
      mnemonicLength: 12
    )
    SampleLog.i("TurnkeyAuth", "created wallet \(walletName)")
    return true
  }
}
