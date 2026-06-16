import Foundation
import Combine

/// Persists the Rain dev API credentials (program `Api-Key` + Rain `userId`) in UserDefaults.
///
/// Replaces the old single "user access token": the Rain API authenticates via the CST flow
/// (see `RainSessionManager`), which needs an Api-Key to mint a session and a userId to scope
/// every issuing call. In production these come from the host server-to-server; the demo lets
/// you paste them on the Collateral Withdraw entry screen.
enum RainAPICredentialsStorage {
  private enum Keys {
    static let apiKey = "RainSDKDemo.rainApiKey"
    static let userId = "RainSDKDemo.rainUserId"
  }

  static var apiKey: String? {
    UserDefaults.standard.string(forKey: Keys.apiKey)
  }

  static var userId: String? {
    UserDefaults.standard.string(forKey: Keys.userId)
  }

  /// True once both an Api-Key and a userId have been saved.
  static var isConfigured: Bool {
    !(apiKey ?? "").isEmpty && !(userId ?? "").isEmpty
  }

  /// Saves both credentials (trimmed). Clears the cached CST so the next call re-mints against
  /// the new credentials.
  static func save(apiKey: String?, userId: String?) {
    setString(apiKey, forKey: Keys.apiKey)
    setString(userId, forKey: Keys.userId)
    Task { await RainSessionManager.shared.invalidate() }
  }

  static func clear() {
    UserDefaults.standard.removeObject(forKey: Keys.apiKey)
    UserDefaults.standard.removeObject(forKey: Keys.userId)
    Task { await RainSessionManager.shared.invalidate() }
  }

  private static func setString(_ value: String?, forKey key: String) {
    if let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty {
      UserDefaults.standard.set(trimmed, forKey: key)
    } else {
      UserDefaults.standard.removeObject(forKey: key)
    }
  }
}

/// Persists and retrieves the Portal session token in UserDefaults. Set at SDK connection view; used for SDK initialization.
enum PortalTokenStorage {
  private static let key = "RainSDKDemo.portalToken"

  static func saveToken(_ token: String?) {
    if let token = token?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty {
      UserDefaults.standard.set(token, forKey: key)
    } else {
      UserDefaults.standard.removeObject(forKey: key)
    }
  }

  static func getToken() -> String? {
    UserDefaults.standard.string(forKey: key)
  }

  static func clearToken() {
    UserDefaults.standard.removeObject(forKey: key)
  }
}

/// Persists Turnkey configuration (org id, auth proxy ids, rpId, optional contact email) in UserDefaults.
/// `TurnkeyContext.configure(...)` is called once with these values before the first `.shared` access.
enum TurnkeyConfigStorage {
  private enum Keys {
    static let organizationId = "RainSDKDemo.turnkey.organizationId"
    static let authProxyConfigId = "RainSDKDemo.turnkey.authProxyConfigId"
    static let apiUrl = "RainSDKDemo.turnkey.apiUrl"
    static let authProxyUrl = "RainSDKDemo.turnkey.authProxyUrl"
    static let rpId = "RainSDKDemo.turnkey.rpId"
    static let email = "RainSDKDemo.turnkey.email"
  }

  static let defaultApiUrl = "https://api.turnkey.com"
  static let defaultAuthProxyUrl = "https://authproxy.turnkey.com"

  static var organizationId: String {
    get { UserDefaults.standard.string(forKey: Keys.organizationId) ?? DemoLocalConfig.turnkeyOrganizationId }
    set { saveString(newValue, forKey: Keys.organizationId) }
  }

  static var authProxyConfigId: String {
    get { UserDefaults.standard.string(forKey: Keys.authProxyConfigId) ?? DemoLocalConfig.turnkeyAuthProxyConfigId }
    set { saveString(newValue, forKey: Keys.authProxyConfigId) }
  }

  static var apiUrl: String {
    get { UserDefaults.standard.string(forKey: Keys.apiUrl) ?? defaultApiUrl }
    set { saveString(newValue, forKey: Keys.apiUrl) }
  }

  static var authProxyUrl: String {
    get { UserDefaults.standard.string(forKey: Keys.authProxyUrl) ?? defaultAuthProxyUrl }
    set { saveString(newValue, forKey: Keys.authProxyUrl) }
  }

  static var rpId: String {
    get { UserDefaults.standard.string(forKey: Keys.rpId) ?? DemoLocalConfig.turnkeyRpId }
    set { saveString(newValue, forKey: Keys.rpId) }
  }

  static var email: String {
    get { UserDefaults.standard.string(forKey: Keys.email) ?? "" }
    set { saveString(newValue, forKey: Keys.email) }
  }

  private static func saveString(_ value: String, forKey key: String) {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      UserDefaults.standard.removeObject(forKey: key)
    } else {
      UserDefaults.standard.set(trimmed, forKey: key)
    }
  }
}

// MARK: - Rain Client Session Token (CST)

/// Decodable response for `POST /v1/issuing/users/{userId}/sessions`.
private struct RainSessionResponse: Decodable {
  let token: String
  let expiresAt: String?
  let userId: String?
}

/// Mints and caches the short-lived Rain Client Session Token (CST).
///
/// Auth model (replaces the old Liquidity Financial bearer flow):
///  1. The host supplies a program-level **Api-Key** and a Rain **userId** (here via
///     `RainAPICredentialsStorage`). In production this minting happens server-to-server.
///  2. The Api-Key is exchanged for a CST at `POST /v1/issuing/users/{userId}/sessions`.
///     The CST is cached and reused until it nears expiry, then re-minted.
///  3. Data endpoints (contracts, signatures) are then called with `Authorization: Bearer cst_…`.
///
/// An `actor` serializes concurrent callers so they share a single mint.
actor RainSessionManager {
  static let shared = RainSessionManager()

  /// Re-mint the CST when it is within this window of expiring.
  private static let refreshBuffer: TimeInterval = 60

  /// Conservative cache lifetime used when the server's `expiresAt` is missing or unparseable,
  /// so a valid CST is still reused instead of re-minted on every call.
  private static let fallbackTTL: TimeInterval = 5 * 60

  private let client = APIClient()
  private var cachedToken: String?
  private var expiresAt: Date?
  /// The userId the cached CST was minted for; a change re-mints regardless of expiry.
  private var cachedUserId: String?

  private init() {}

  /// Drops the cached CST so the next `validToken()` re-mints (e.g. after credentials change).
  func invalidate() {
    cachedToken = nil
    expiresAt = nil
    cachedUserId = nil
  }

  /// Returns a valid CST, minting a new one if none is cached, the cached one is near expiry,
  /// or the userId changed.
  func validToken() async throws -> String {
    guard
      let apiKey = RainAPICredentialsStorage.apiKey, !apiKey.isEmpty,
      let userId = RainAPICredentialsStorage.userId, !userId.isEmpty
    else {
      throw APIError.notConfigured
    }

    if let token = cachedToken, let expiry = expiresAt, cachedUserId == userId,
       Date().addingTimeInterval(Self.refreshBuffer) < expiry {
      return token
    }

    let session = try await createSession(apiKey: apiKey, userId: userId)
    cachedToken = session.token
    // Prefer the server's expiry; if it's missing or unparseable, fall back to a short TTL so
    // the CST is still cached rather than re-minted on every request.
    expiresAt = session.expiresAt.flatMap(Self.parseDate)
      ?? Date().addingTimeInterval(Self.fallbackTTL)
    cachedUserId = userId
    return session.token
  }

  private func createSession(apiKey: String, userId: String) async throws -> RainSessionResponse {
    try await client.request(
      .createSession(userId: userId),
      as: RainSessionResponse.self,
      extraHeaders: ["Api-Key": apiKey]
    )
  }

  private static func parseDate(_ string: String) -> Date? {
    let withFractional = ISO8601DateFormatter()
    withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = withFractional.date(from: string) { return date }
    return ISO8601DateFormatter().date(from: string)
  }
}

// MARK: - Rain API context (shared, app-level)

/// App-wide Rain dev API session, owned by the home screen and observed by feature screens.
///
/// The home screen enters the Api-Key + User ID here and calls `authenticate()`, which mints a
/// CST and fetches the first collateral contract. The fetched `contract` is then published so
/// downstream screens (EIP-712 / Build Withdraw builders, Collateral Withdraw) can prefill from
/// it without re-authenticating — the CST itself stays inside `RainSessionManager`.
@MainActor
final class RainAPIContext: ObservableObject {
  static let shared = RainAPIContext()

  @Published var apiKey: String
  @Published var userId: String

  /// First collateral contract fetched after authenticating; nil until authenticated.
  @Published private(set) var contract: RainCollateralContractResponse?
  @Published private(set) var isAuthenticating = false
  @Published var error: Error?

  private let repository = CreditContractsRepository()

  private init() {
    apiKey = RainAPICredentialsStorage.apiKey ?? ""
    userId = RainAPICredentialsStorage.userId ?? ""
  }

  var isAuthenticated: Bool { contract != nil }

  var canAuthenticate: Bool {
    !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !isAuthenticating
  }

  /// The token addresses of the fetched contract (non-empty only).
  var contractTokenAddresses: [String] {
    (contract?.tokens ?? []).compactMap { $0.address }.filter { !$0.isEmpty }
  }

  /// Saves the credentials, mints a CST, and fetches the first collateral contract.
  func authenticate() async {
    let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    let user = userId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !key.isEmpty, !user.isEmpty else { return }

    isAuthenticating = true
    error = nil
    defer { isAuthenticating = false }

    RainAPICredentialsStorage.save(apiKey: key, userId: user)

    do {
      contract = try await repository.getCreditContracts()
    } catch {
      contract = nil
      self.error = error
    }
  }

  func reset() {
    contract = nil
    error = nil
  }
}
