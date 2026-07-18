import Foundation
import PortalSwift
import RainCore

/// Configuration for the Portal provider. Mirrors Android's `PortalConfig`.
public struct PortalConfig: @unchecked Sendable {
  /// A valid Portal session token.
  public let sessionToken: String

  public init(sessionToken: String) {
    self.sessionToken = sessionToken
  }
}

/// Registrable descriptor for the Portal MPC wallet provider. Lives in the `RainPortal` module so
/// a Portal-only client never resolves Turnkey or Privy.
///
/// ```swift
/// import RainCore
/// import RainPortal
///
/// let rain = try RainSdk.builder()
///     .rpcEndpoints([43114: "https://…"])
///     .register(PortalProvider(PortalConfig(sessionToken: "<token>")))
///     .build()
/// let client = try await rain.provider(.portal)
/// ```
public struct PortalProvider: RainProvider {
  private let config: PortalConfig
  private let onPortalCreated: (@Sendable (Portal) -> Void)?

  /// - Parameters:
  ///   - config: Portal configuration (session token).
  ///   - onPortalCreated: Optional hook invoked with the underlying `Portal` instance once it's
  ///     constructed during resolution. Lets a host reach Portal-specific APIs not on the Rain
  ///     port (e.g. `recoverWallet`, `backupWallet`) without core exposing PortalSwift types.
  public init(_ config: PortalConfig, onPortalCreated: (@Sendable (Portal) -> Void)? = nil) {
    self.config = config
    self.onPortalCreated = onPortalCreated
    // Register Portal's error mapping with core once, so Portal vendor errors classify correctly
    // without RainCore importing PortalSwift.
    PortalErrorMapping.registerOnce()
  }

  public var id: ProviderId { .portal }

  public var capabilities: Set<Capability> { [.export, .recovery] }

  public func create(context: ProviderContext) async throws -> any RainWalletProvider {
    guard !config.sessionToken.isEmpty else {
      throw RainSDKError.unauthorized
    }

    // Configs are already validated by RainSdk.Builder.build(); just map to Portal's form.
    let rpcConfig = Self.portalRpcConfig(from: context.networkConfigs)

    do {
      let portal = try Portal(
        config.sessionToken,
        withRpcConfig: rpcConfig,
        autoApprove: true,
        iCloud: ICloudStorage(),
        keychain: PortalKeychain(),
        passwords: PasswordStorage()
      )
      RainLogger.info("Rain SDK: Registered Portal instance with \(context.networkConfigs.count) network(s)")
      onPortalCreated?(portal)
      return PortalWalletProviderAdapter(
        portal: portal,
        tokenStore: context.tokenStore
      )
    } catch let error as RainSDKError {
      throw error
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  /// Maps network configs to Portal's `eip155:<chainId> → rpcUrl` RPC config form.
  static func portalRpcConfig(from configs: [NetworkConfig]) -> [String: String] {
    var rpcConfig: [String: String] = [:]
    for cfg in configs {
      rpcConfig["eip155:\(cfg.chainId)"] = cfg.rpcUrl
    }
    return rpcConfig
  }
}
