import Foundation
import PrivySDK

/// Sample-app glue that drives Privy's iOS SDK end-to-end (init, email OTP, embedded-wallet
/// provisioning) so the host app can hand a ready `Privy` singleton to
/// `RainSDKService.initializePrivy(privy:)`.
///
/// This file is NOT part of Rain SDK. It is reference code a host app would write itself — Rain SDK
/// intentionally does not own Privy auth. Copy / adapt for your own app.
@MainActor
final class PrivyAuthSample {
  static let shared = PrivyAuthSample()

  /// Privy must be a single instance for the app's lifetime; hold it here after init.
  private var instance: (any Privy)?

  private init() {}

  /// Hand this to `RainSDKService.initializePrivy(privy:)` once auth is complete.
  var privy: any Privy {
    guard let instance else {
      fatalError("PrivyAuthSample.initialize(...) not called yet")
    }
    return instance
  }

  /// Initializes the Privy singleton (idempotent — reuses the existing instance).
  func initialize(appId: String, appClientId: String) {
    guard instance == nil else { return }
    instance = PrivySdk.initialize(
      config: PrivyConfig(appId: appId, appClientId: appClientId)
    )
  }

  /// True when Privy restored an authenticated session from a prior run (skips the OTP round-trip).
  func hasActiveSession() async -> Bool {
    guard let instance else { return false }
    if case .authenticated = await instance.getAuthState() { return true }
    return false
  }

  /// Logs the Privy user out. Safe no-op if not authenticated.
  func logout() async {
    guard let user = await instance?.getUser() else { return }
    await user.logout()
  }

  /// Sends an email OTP. Throws on failure.
  func sendEmailOtp(email: String) async throws {
    try await privy.email.sendCode(to: email)
  }

  /// Verifies the OTP and creates a Privy session, then ensures an embedded Ethereum wallet exists.
  /// Throws on failure.
  func verifyEmailOtp(code: String, email: String) async throws {
    _ = try await privy.email.loginWithCode(code, sentTo: email)
    try await ensureEthereumWallet()
  }

  /// Ensures the authenticated user has an embedded Ethereum wallet, creating one if needed.
  func ensureEthereumWallet() async throws {
    guard let user = await privy.getUser() else {
      throw NSError(
        domain: "RainSDKDemo.Privy", code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Privy user not authenticated"])
    }
    if user.embeddedEthereumWallets.isEmpty {
      _ = try await user.createEthereumWallet(allowAdditional: false)
    }
  }
}
