import Foundation

/// Persists and retrieves the API access token in UserDefaults. Set at token input view; used by APIClient for request headers.
enum AuthTokenStorage {
  private static let key = "RainSDKDemo.userAccessToken"

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
