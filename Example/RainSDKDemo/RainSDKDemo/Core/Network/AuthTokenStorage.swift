import Foundation
import Combine

/// Persists the Rain dev API credentials (program `Api-Key` + Rain `userId`) in UserDefaults.
///
/// The Rain API itself (CST minting, contracts, withdrawal signatures) now lives inside the
/// SDK — the demo only stores the credentials and pushes them in via
/// `RainSdk.configureRainApi`. In production these come from the host server-to-server; the
/// demo lets you paste them on the Collateral Withdraw entry screen.
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

  /// Saves both credentials (trimmed) and pushes them into the SDK, whose cached client
  /// session token then re-mints lazily against the new pair.
  static func save(apiKey: String?, userId: String?) {
    setString(apiKey, forKey: Keys.apiKey)
    setString(userId, forKey: Keys.userId)
    Task { @MainActor in
      RainSDKService.shared.configureRainApi(apiKey: apiKey ?? "", userId: userId ?? "")
    }
  }

  static func clear() {
    UserDefaults.standard.removeObject(forKey: Keys.apiKey)
    UserDefaults.standard.removeObject(forKey: Keys.userId)
    Task { @MainActor in
      RainSDKService.shared.configureRainApi(apiKey: "", userId: "")
    }
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

/// Persists Privy configuration (app id, app client id, contact email) in UserDefaults.
/// `PrivySdk.initialize(...)` is called once with these values before the first use.
enum PrivyConfigStorage {
  private enum Keys {
    static let appId = "RainSDKDemo.privy.appId"
    static let appClientId = "RainSDKDemo.privy.appClientId"
    static let email = "RainSDKDemo.privy.email"
  }

  static var appId: String {
    get { UserDefaults.standard.string(forKey: Keys.appId) ?? DemoLocalConfig.privyAppId }
    set { saveString(newValue, forKey: Keys.appId) }
  }

  static var appClientId: String {
    get { UserDefaults.standard.string(forKey: Keys.appClientId) ?? DemoLocalConfig.privyAppClientId }
    set { saveString(newValue, forKey: Keys.appClientId) }
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

// MARK: - Rain API context (shared, app-level)

/// App-wide Rain dev API session, owned by the home screen and observed by feature screens.
///
/// The home screen enters the Api-Key + User ID here and calls `authenticate()`, which
/// configures the SDK and fetches the first collateral contract. The fetched `contract` is
/// then published so downstream screens (EIP-712 / Build Withdraw builders, Collateral
/// Withdraw) can prefill from it without re-authenticating — the CST stays inside the SDK.
@MainActor
final class RainAPIContext: ObservableObject {
  static let shared = RainAPIContext()

  @Published var apiKey: String
  @Published var userId: String

  /// First collateral contract fetched after authenticating; nil until authenticated.
  @Published private(set) var contract: RainCollateralContractResponse?
  @Published private(set) var isAuthenticating = false
  @Published var error: Error?

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
    // save() pushes the credentials into the SDK on the main actor via a Task; configure
    // directly as well so this fetch can't race ahead of it.
    RainSDKService.shared.configureRainApi(apiKey: key, userId: user)

    do {
      contract = RainCollateralContractResponse(
        contract: try await RainSDKService.shared.fetchCollateralContract()
      )
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
