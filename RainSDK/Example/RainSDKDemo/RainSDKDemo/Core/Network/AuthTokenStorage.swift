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
