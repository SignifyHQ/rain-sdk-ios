import Foundation

/// Per-developer local config for the demo app. Edit these values for your local Turnkey setup.
/// They prefill the SDK Connection screen on a fresh install / first launch.
///
/// To keep your edits out of git:
///   git update-index --skip-worktree Example/RainSDKDemo/RainSDKDemo/DemoLocalConfig.swift
/// To start tracking again:
///   git update-index --no-skip-worktree Example/RainSDKDemo/RainSDKDemo/DemoLocalConfig.swift
enum DemoLocalConfig {
  /// Turnkey parent organization id (UUID from the Turnkey dashboard).
  static let turnkeyOrganizationId = "e10138e1-b564-441d-bc67-f0a4ad2b4658"

  /// Auth Proxy config id (UUID from Turnkey dashboard → Settings → Auth Proxy).
  static let turnkeyAuthProxyConfigId = "fb2e10c2-98de-4a9f-842b-f666e91d84d5"

  /// Relying Party id — the hostname (no scheme, no path) of the AASA you're serving.
  /// Must match the `webcredentials:<host>` entry in RainSDKDemo.entitlements.
  static let turnkeyRpId = "bea6-86-187-162-5.ngrok-free.app"

  static let chainId = "84532"

  static var chainIdInt: Int { Int(chainId)! }

  static func transactionExplorerURL(hash: String, chainId: Int) -> URL? {
    let base: String?
    switch chainId {
    case 84532: base = "https://sepolia.basescan.org/tx/"
    case 43114: base = "https://snowtrace.io/tx/"
    case 43113: base = "https://testnet.snowtrace.io/tx/"
    default: base = nil
    }
    guard let base else { return nil }
    return URL(string: base + hash)
  }
}
