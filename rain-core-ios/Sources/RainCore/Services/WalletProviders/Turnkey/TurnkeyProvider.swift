import Combine
import Foundation
import TurnkeySwift

/// Configuration for the Turnkey provider. Turnkey authentication (passkeys / auth proxy / OAuth /
/// OTP) happens **outside** Rain — the host drives Turnkey's Swift SDK and hands the authenticated
/// `TurnkeyContext` to Rain.
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
  /// Expiry/refresh/retry behavior for the session guarding every wallet call.
  public let sessionPolicy: TurnkeySessionPolicy
  /// Re-auth hook: invoked once per session death when the Turnkey session dies and cannot be
  /// refreshed — whether that is discovered during a wallet call or by the passive session
  /// watcher. Not necessarily on the main thread; hop to the main actor before touching UI,
  /// and never call back into the SDK synchronously from it. Restart authentication from here.
  public let onSessionExpired: (@Sendable () -> Void)?

  public init(
    turnkey: TurnkeyContext,
    walletAddress: String? = nil,
    sessionPolicy: TurnkeySessionPolicy = TurnkeySessionPolicy(),
    onSessionExpired: (@Sendable () -> Void)? = nil
  ) {
    self.turnkey = turnkey
    self.walletAddress = walletAddress
    self.sessionPolicy = sessionPolicy
    self.onSessionExpired = onSessionExpired
  }
}

/// Registrable descriptor for the Turnkey wallet provider.
///
/// Turnkey is bundled inside `RainCore` for now (it will graduate to a standalone `rain-turnkey`
/// module later). It implements `RainProvider` like any adapter, but relies on the core-internal
/// `ProviderContext` EVM chain reader that out-of-core adapters cannot reach yet — that must be
/// widened when the module is extracted.
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
  private let coordinator: TurnkeySessionCoordinator

  public init(_ config: TurnkeyConfig) {
    self.config = config
    self.coordinator = TurnkeySessionCoordinator(
      turnkey: config.turnkey,
      policy: config.sessionPolicy,
      onSessionExpired: config.onSessionExpired
    )
  }

  public var id: ProviderId { .turnkey }

  public var capabilities: Set<Capability> { [.multiChain, .biometricGate] }

  /// The Turnkey session as seen at the Rain boundary, over time. Emits on every Turnkey
  /// auth/session change and when an active session passes its expiry, so a host can react to
  /// a session dying silently without waiting for a wallet call to fail.
  public var sessionState: AnyPublisher<TurnkeySessionState, Never> {
    coordinator.sessionStates
  }

  /// Snapshot of `sessionState` right now.
  public func currentSessionState() -> TurnkeySessionState {
    coordinator.currentState()
  }

  /// Forces a Turnkey session refresh (new JWT, extended expiry) regardless of remaining
  /// lifetime. Throws `RainSDKError.tokenExpired` when the session cannot be refreshed — the
  /// host must re-authenticate.
  public func refreshSession() async throws {
    try await coordinator.refreshNow()
  }

  /// Stops the passive session watcher. Call when discarding this provider (e.g. rebuilding
  /// the SDK for a new login) so a stale provider stops observing the process-wide Turnkey
  /// singleton and can never fire its expiry hook again.
  public func close() {
    coordinator.stopMonitoring()
  }

  public func create(context: ProviderContext) async throws -> any RainWalletProvider {
    // The watcher only exists to drive the host's re-auth hook; without one there is nothing
    // to notify and no reason to hold a subscription on the Turnkey singleton.
    if config.onSessionExpired != nil {
      coordinator.startMonitoring()
    }

    let provider = TurnkeyWalletProviderAdapter(
      turnkey: config.turnkey,
      networkConfigs: context.networkConfigs,
      walletAddress: config.walletAddress,
      chainReader: context.evmChainReader,
      solanaSupport: context.solanaSupport,
      tokenStore: context.tokenStore,
      sessionCoordinator: coordinator
    )
    // Probe the wallet so an unusable context fails fast at resolution time (parity with the
    // old initializeTurnkey behaviour).
    _ = try await provider.address()
    return provider
  }
}
