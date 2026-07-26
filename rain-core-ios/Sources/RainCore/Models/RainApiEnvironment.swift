import Foundation

/// Rain issuing API environment the SDK talks to.
///
/// Selected at build time via `RainSdk.Builder.rainApiEnvironment(_:)`; defaults to `.dev`.
public enum RainApiEnvironment: Sendable {
  /// Rain development environment (`api-dev.rain.xyz`). The default.
  case dev

  /// Rain production environment (`api.rain.xyz`).
  case production

  /// Escape hatch for staging or self-hosted gateways: any explicit base URL.
  case custom(URL)

  public var baseURL: URL {
    switch self {
    case .dev:
      return URL(string: "https://api-dev.rain.xyz")!
    case .production:
      return URL(string: "https://api.rain.xyz")!
    case .custom(let url):
      return url
    }
  }
}
