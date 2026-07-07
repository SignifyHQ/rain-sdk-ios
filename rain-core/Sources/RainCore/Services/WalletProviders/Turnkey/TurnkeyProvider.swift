import Foundation
import TurnkeySwift

/// Configuration for the Turnkey provider. Turnkey authentication (passkeys / auth proxy / OAuth /
/// OTP) happens **outside** Rain — the host drives Turnkey's Swift SDK and hands the authenticated
/// `TurnkeyContext` to Rain. Mirrors Android's `TurnkeyConfig`.
///
/// `@unchecked Sendable`: `TurnkeyContext` is a host-owned reference type with mutable published
/// state that Rain reads from arbitrary executors. Host contract: finish authentication before
/// handing the context to Rain, and don't mutate it (re-auth, logout, wallet switch) while Rain
/// calls are in flight — after such changes, build a new `RainSdk` / re-resolve the provider.
public struct TurnkeyConfig: @unchecked Sendable {
  /// An authenticated Turnkey context.
  public let turnkey: TurnkeyContext
  /// Optional explicit EVM wallet address. When `nil`, Rain uses the first Ethereum account from
  /// the Turnkey context.
  public let walletAddress: String?

  public init(turnkey: TurnkeyContext, walletAddress: String? = nil) {
    self.turnkey = turnkey
    self.walletAddress = walletAddress
  }
}

/// Registrable descriptor for the Turnkey wallet provider.
///
/// Turnkey is bundled inside `RainCore` for now (it will graduate to a standalone `rain-turnkey`
/// module later). It implements `RainProvider` like any adapter, but relies on core-internal
/// `ProviderContext` members (transaction builder, chain reader) that out-of-core adapters
/// cannot reach yet — those must be widened when the module is extracted.
///
/// ```swift
/// let rain = try RainSdk.builder()
///     .rpcEndpoints([43114: "https://…"])
///     .register(TurnkeyProvider(TurnkeyConfig(turnkey: turnkeyContext)))
///     .build()
/// let client = try await rain.provider(.turnkey)
/// ```
public struct TurnkeyProvider: RainProvider {
  private let config: TurnkeyConfig

  public init(_ config: TurnkeyConfig) {
    self.config = config
  }

  public var id: ProviderId { .turnkey }

  public var capabilities: Set<Capability> { [.multiChain, .biometricGate] }

  public func create(context: ProviderContext) async throws -> any RainWalletProvider {
    let provider = TurnkeyWalletProviderAdapter(
      turnkey: config.turnkey,
      transactionBuilder: context.transactionBuilder,
      networkConfigs: context.networkConfigs,
      walletAddress: config.walletAddress,
      chainReader: context.evmChainReader,
      tokenStore: context.tokenStore
    )
    // Probe the wallet so an unusable context fails fast at resolution time (parity with the
    // old initializeTurnkey behaviour).
    _ = try await provider.address()
    return provider
  }
}
