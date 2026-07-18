import Foundation

/// The credential pair a client session token is minted against.
internal struct RainApiCredentials: Equatable, Sendable {
  let apiKey: String
  let userId: String
}

/// Holds the Rain API base URL (fixed at build time) and the host-supplied credentials
/// (mutable at runtime via `RainSdk.configureRainApi`). The SDK never persists these.
///
/// Mutable state stays behind the lock — `RainSdk` is `@unchecked Sendable`.
internal final class RainApiConfigStore: @unchecked Sendable {
  let baseURL: URL

  private let lock = NSLock()
  private var apiKey: String = ""
  private var userId: String = ""

  init(baseURL: URL) {
    self.baseURL = baseURL
  }

  /// Sets or replaces the credential pair. Values are trimmed; blank clears.
  func setCredentials(apiKey: String, userId: String) {
    lock.lock(); defer { lock.unlock() }
    self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    self.userId = userId.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func clear() {
    lock.lock(); defer { lock.unlock() }
    apiKey = ""
    userId = ""
  }

  var isConfigured: Bool {
    lock.lock(); defer { lock.unlock() }
    return !apiKey.isEmpty && !userId.isEmpty
  }

  /// - Throws: `RainSDKError.rainApiNotConfigured` when either value is blank.
  func credentials() throws -> RainApiCredentials {
    lock.lock(); defer { lock.unlock() }
    guard !apiKey.isEmpty, !userId.isEmpty else {
      throw RainSDKError.rainApiNotConfigured
    }
    return RainApiCredentials(apiKey: apiKey, userId: userId)
  }
}
