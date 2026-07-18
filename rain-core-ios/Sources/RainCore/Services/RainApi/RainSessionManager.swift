import Foundation

/// A minted client session token plus its parsed expiry (nil when unparseable).
internal struct RainSession: Sendable {
  let token: String
  let expiresAt: Date?
}

/// Mints and caches the short-lived Rain Client Session Token (CST).
///
/// A cached CST is reused while it was minted for the current credential pair and is more
/// than `refreshBuffer` from expiry; otherwise `mint` runs (actor-serialized, so concurrent
/// callers share one mint). A session without a parseable expiry is kept for `fallbackTTL`
/// from mint time. Mirrors Android's `RainSessionStore`.
internal actor RainSessionManager {
  /// Re-mint the CST when it is within this window of expiring.
  internal static let refreshBuffer: TimeInterval = 60

  /// Assumed lifetime when the API returns no parseable `expiresAt`.
  internal static let fallbackTTL: TimeInterval = 5 * 60

  private let now: @Sendable () -> Date
  private let mint: @Sendable (RainApiCredentials) async throws -> RainSession

  private var cached: RainSession?
  private var cachedFor: RainApiCredentials?

  init(
    now: @escaping @Sendable () -> Date = { Date() },
    mint: @escaping @Sendable (RainApiCredentials) async throws -> RainSession
  ) {
    self.now = now
    self.mint = mint
  }

  func validToken(for credentials: RainApiCredentials) async throws -> String {
    if let session = cached, cachedFor == credentials, !isNearExpiry(session) {
      return session.token
    }

    let minted = try await mint(credentials)
    cached = RainSession(
      token: minted.token,
      expiresAt: minted.expiresAt ?? now().addingTimeInterval(Self.fallbackTTL)
    )
    cachedFor = credentials
    return minted.token
  }

  /// Drops the cached CST so the next `validToken` re-mints (e.g. after a 401).
  func invalidate() {
    cached = nil
    cachedFor = nil
  }

  private func isNearExpiry(_ session: RainSession) -> Bool {
    guard let expiry = session.expiresAt else { return true }
    return now().addingTimeInterval(Self.refreshBuffer) >= expiry
  }
}
