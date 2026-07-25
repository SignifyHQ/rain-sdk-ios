import Foundation
import PrivySDK
import RainCore

/// Configuration for the Privy provider.
///
/// Privy authentication and `PrivySdk.initialize(...)` happen outside Rain via the Privy iOS SDK:
/// initialize the `Privy` singleton at app start, log the user in, ensure an embedded Ethereum
/// wallet exists (`user.createEthereumWallet()`), then hand the singleton here.
public struct PrivyConfig: Sendable {
  /// The initialized, authenticated Privy singleton.
  public let privy: any Privy

  /// Optional explicit embedded-wallet address; when `nil` Rain uses the user's first embedded
  /// Ethereum wallet.
  public let walletAddress: String?

  public init(privy: any Privy, walletAddress: String? = nil) {
    self.privy = privy
    self.walletAddress = walletAddress
  }
}

/// Privy adapter — the registrable ``RainProvider`` for Privy's embedded-key signer.
///
/// Custody (signing, broadcasting) routes through Privy's EIP-1193 embedded-wallet provider;
/// balance / fee reads use Rain's configured RPC via ``PrivyRpcClient``.
///
/// On Solana: register the cluster's RPC URL and create an embedded Solana wallet
/// (`user.createSolanaWallet()`); `getAddress`, `getBalance`, native SOL and SPL token sends
/// resolve against that account. Fee estimates and typed-data stay EVM-only, and an embedded
/// Ethereum wallet is always required.
///
/// ```swift
/// import RainCore
/// import RainPrivy
///
/// let privy = PrivySdk.initialize(config: PrivyConfig(appId: "…", appClientId: "…"))
/// // …authenticate the user and ensure an embedded Ethereum wallet exists…
/// let rain = try RainSdk.builder()
///     .rpcEndpoints([43114: "https://…"])
///     .register(PrivyProvider(PrivyConfig(privy: privy)))
///     .build()
/// let client = try await rain.provider(.privy)
/// ```
public struct PrivyProvider: RainProvider {
  private let config: PrivyConfig

  public init(_ config: PrivyConfig) {
    self.config = config
    // Register Privy's error mapping with core once, so Privy vendor errors classify into
    // RainSDKError cases without RainCore importing PrivySDK.
    PrivyErrorMapping.registerOnce()
  }

  public var id: ProviderId { .privy }

  /// Privy holds an exportable embedded key with a recovery flow.
  public var capabilities: Set<Capability> { [.export, .recovery] }

  public func create(context: ProviderContext) async throws -> any RainWalletProvider {
    let provider = PrivyWalletProvider(
      manager: PrivyManager(privy: config.privy),
      rpcEndpoints: context.rpcEndpoints,
      tokenStore: context.tokenStore,
      solanaSupport: context.solanaSupport,
      walletAddressOverride: config.walletAddress
    )

    // Probe — ensures Privy has an embedded Ethereum wallet available before handing it out.
    do {
      _ = try await provider.address()
    } catch let error as RainSDKError {
      throw error
    } catch {
      throw RainSDKError.from(underlying: error)
    }

    RainLogger.info("Rain SDK: Registered Privy instance with \(context.networkConfigs.count) network(s)")
    return provider
  }
}
