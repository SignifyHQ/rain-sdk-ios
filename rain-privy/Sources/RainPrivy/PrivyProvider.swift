import Foundation
import RainCore

/// Configuration for the Privy provider.
///
/// Skeleton: the real Privy embedded-wallet integration (app id, authenticated Privy session /
/// embedded-key handle) will be carried here once the adapter is built out. Mirrors Android's
/// `PrivyConfig`.
public struct PrivyConfig: Sendable {
  /// The Privy app id.
  public let appId: String

  public init(appId: String) {
    self.appId = appId
  }
}

/// Privy adapter — the registrable ``RainProvider`` for Privy's embedded-key signer.
///
/// **Skeleton only.** This module exists to prove the modular architecture's thesis: a net-new
/// provider arrives as its own artifact (`rain-privy`) with its own vendor dependency, and costs
/// existing Portal / Turnkey clients nothing. The signing/wallet implementation is not wired yet —
/// ``create(context:)`` returns a ``PrivyWalletProvider`` whose operations throw until the Privy
/// SDK is integrated.
public struct PrivyProvider: RainProvider {
  private let config: PrivyConfig

  public init(_ config: PrivyConfig) {
    self.config = config
  }

  public var id: ProviderId { .privy }

  /// Privy holds an exportable embedded key with a recovery flow.
  public var capabilities: Set<Capability> { [.export, .recovery] }

  public func create(context: ProviderContext) async throws -> any RainWalletProvider {
    PrivyWalletProvider()
  }
}
