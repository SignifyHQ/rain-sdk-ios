import Foundation
import Web3

/// Entry point and provider registry for the Rain SDK.
///
/// Built via ``RainSdk/builder()``: register RPC endpoints, one or more provider descriptors, and
/// optional tokens, then `build()`. Resolve a wallet-bound ``RainClient`` by id (`provider(_:)`)
/// or by capability (`first { }`). The registry is designed for the multi-provider case; a
/// single-provider app is simply the trivial `N = 1` instance of it.
///
/// Wallet-agnostic building (EIP-712 message, withdraw calldata, transaction parameters) is
/// available directly off `RainSdk` with no provider resolved.
public final class RainSdk: @unchecked Sendable {
  private let networkConfigs: [NetworkConfig]
  private let rpcEndpoints: [Int: String]
  private let descriptors: [ProviderId: RainProvider]
  private let registrationOrder: [ProviderId]

  // Shared, vendor-free infrastructure, built once and reused across every resolved provider.
  private let transactionBuilder: TransactionBuilderService
  private let tokenStore: TokenMetadataStore
  private let evmChainReader: EVMChainReader
  private let providerContext: ProviderContext

  // Rain issuing API (sessions, contracts, withdrawal signatures).
  private let rainApiConfig: RainApiConfigStore
  private let rainApiService: RainApiService

  // Resolved clients are cached by provider id (lazy, resolved-once). We cache the *in-flight
  // resolution Task*, not the finished client, so concurrent first-resolutions of the same id
  // share one Task and `create(context:)` runs exactly once. Boxed in a class so we can identity-
  // compare on failure eviction.
  private final class ResolveBox {
    let task: Task<RainClient, Error>
    init(_ task: Task<RainClient, Error>) { self.task = task }
  }
  private var resolveBoxes: [ProviderId: ResolveBox] = [:]
  private let clientsLock = NSLock()

  fileprivate init(
    networkConfigs: [NetworkConfig],
    descriptors: [ProviderId: RainProvider],
    registrationOrder: [ProviderId],
    registeredTokens: [TokenInfo],
    rainApiEnvironment: RainApiEnvironment,
    initialRainApiCredentials: (apiKey: String, userId: String)?
  ) {
    self.networkConfigs = networkConfigs
    self.descriptors = descriptors
    self.registrationOrder = registrationOrder

    var endpoints: [Int: String] = [:]
    for config in networkConfigs { endpoints[config.chainId] = config.rpcUrl }
    self.rpcEndpoints = endpoints

    let reader = EVMChainReader(networkConfigs: networkConfigs)
    let store = TokenMetadataStore(chainReader: reader, seedTokens: registeredTokens)
    let builder = TransactionBuilderService(networkConfigs: networkConfigs)
    self.evmChainReader = reader
    self.tokenStore = store
    self.transactionBuilder = builder
    self.providerContext = ProviderContext(
      rpcEndpoints: endpoints,
      networkConfigs: networkConfigs,
      tokenStore: store,
      transactionBuilder: builder,
      evmChainReader: reader
    )

    let apiConfig = RainApiConfigStore(baseURL: rainApiEnvironment.baseURL)
    if let credentials = initialRainApiCredentials {
      apiConfig.setCredentials(apiKey: credentials.apiKey, userId: credentials.userId)
    }
    self.rainApiConfig = apiConfig
    self.rainApiService = RainApiService(configStore: apiConfig, tokenStore: store, chainReader: reader)
  }

  // MARK: - Registry introspection

  /// The set of registered provider ids.
  public var providerIds: Set<ProviderId> { Set(descriptors.keys) }

  /// All registered provider descriptors, in registration order.
  public var providers: [any RainProvider] { registrationOrder.compactMap { descriptors[$0] } }

  // MARK: - Resolution

  /// Resolves (and caches) the wallet-bound ``RainClient`` for the given provider id.
  /// Suspends because `create(context:)` may materialize / probe the vendor wallet on first access.
  ///
  /// - Throws: `RainSDKError.providerNotRegistered` if no provider is registered under `id`.
  public func provider(_ id: ProviderId) async throws -> RainClient {
    guard descriptors[id] != nil else {
      throw RainSDKError.providerNotRegistered(details: "No provider registered for id '\(id.rawValue)'")
    }

    // Get-or-create the shared resolution Task under the lock — the only critical section. The
    // first caller installs the Task; concurrent callers find and await the same one, so
    // `create(context:)` (and its side effects) fire once.
    let box: ResolveBox = {
      clientsLock.lock(); defer { clientsLock.unlock() }
      if let existing = resolveBoxes[id] { return existing }
      let task = Task<RainClient, Error> { [self] in
        let descriptor = descriptors[id]!
        let walletProvider: any RainWalletProvider
        do {
          walletProvider = try await descriptor.create(context: providerContext)
        } catch {
          throw RainSDKError.from(underlying: error)
        }
        return RainSdkManager(
          walletProvider: walletProvider,
          networkConfigs: networkConfigs,
          transactionBuilder: transactionBuilder,
          tokenStore: tokenStore,
          providerId: descriptor.id,
          capabilities: descriptor.capabilities
        )
      }
      let newBox = ResolveBox(task)
      resolveBoxes[id] = newBox
      return newBox
    }()

    do {
      return try await box.task.value
    } catch {
      // Failed resolution isn't cached — evict so a later call can retry. Only clear if the stored
      // box is still ours; a concurrent retry may already have installed a fresh one.
      clientsLock.withLock {
        if resolveBoxes[id] === box { resolveBoxes[id] = nil }
      }
      throw error
    }
  }

  /// Tears down all resolved clients and clears the Rain API credentials and cached session
  /// token. Idempotent.
  ///
  /// The configuration (network configs, descriptors, token store) is immutable state fixed at
  /// `build()`, so this instance stays usable: the next `provider(_:)` / `first(where:)` call
  /// re-resolves the provider from scratch (re-running `create(context:)`). Build a new `RainSdk`
  /// via ``builder()`` to change configuration.
  public func reset() {
    let boxes: [ResolveBox] = clientsLock.withLock {
      let values = Array(resolveBoxes.values)
      resolveBoxes.removeAll()
      return values
    }
    // Reset each resolved client, and cancel in-flight resolutions so they don't finish
    // into an evicted slot.
    for box in boxes {
      let task = box.task
      task.cancel()
      Task {
        if let client = try? await task.value { client.reset() }
      }
    }
    rainApiConfig.clear()
    // Fire-and-forget: credentials were cleared synchronously above, so calls racing this drop
    // fail with rainApiNotConfigured until configureRainApi supplies a pair again.
    Task { [rainApiService] in await rainApiService.invalidateSession() }
    RainLogger.info("Rain SDK: Reset (resolved clients evicted; Rain API session and credentials cleared)")
  }

  /// Resolves the first registered provider (in registration order) matching `predicate`, e.g.
  /// `rain.first { $0.capabilities.contains(.export) }`.
  ///
  /// - Throws: `RainSDKError.providerNotRegistered` if no registered provider matches.
  public func first(where predicate: (any RainProvider) -> Bool) async throws -> RainClient {
    for id in registrationOrder {
      guard let descriptor = descriptors[id] else { continue }
      if predicate(descriptor) {
        return try await provider(id)
      }
    }
    throw RainSDKError.providerNotRegistered(details: "No registered provider matches the requested capability")
  }

  // MARK: - Wallet-agnostic transaction building

  /// Reads the collateral's current admin nonce — the value `buildEIP712Message` binds when
  /// `nonce` is omitted.
  public func getLatestNonce(chainId: Int, proxyAddress: String) async throws -> BigUInt {
    try await transactionBuilder.getLatestNonce(proxyAddress: proxyAddress, chainId: chainId)
  }

  /// Whether `walletAddress` is an admin of the collateral at `proxyAddress`.
  ///
  /// - Returns: The contract's answer, or `nil` when the check could not run (RPC failure, or a
  ///   collateral exposing no `isAdmin`). Treat `nil` as unknown and proceed, never as "not
  ///   authorized".
  public func isCollateralAdmin(
    chainId: Int,
    proxyAddress: String,
    walletAddress: String
  ) async -> Bool? {
    await transactionBuilder.isCollateralAdmin(
      proxyAddress: proxyAddress,
      walletAddress: walletAddress,
      chainId: chainId
    )
  }

  /// Builds the EIP-712 message the wallet signs to authorize a withdrawal, along with the salt
  /// bound into it. Pass `nonce: nil` to read the collateral's current nonce on chain.
  public func buildEIP712Message(
    chainId: Int,
    walletAddress: String,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    nonce: BigUInt? = nil
  ) async throws -> RainEIP712Message {
    try await WithdrawalBuilder.buildEIP712Message(
      builder: transactionBuilder,
      chainId: chainId,
      walletAddress: walletAddress,
      addresses: addresses,
      amount: amount,
      decimals: decimals,
      nonce: nonce
    )
  }

  /// ABI-encodes the `withdrawAsset` call for the collateral controller.
  ///
  /// Pure encoding — no RPC, so it needs no chain id.
  ///
  /// - Parameters:
  ///   - executorSignature: Rain's authorization, from ``fetchAdminSignature(chainId:tokenAddress:amountBaseUnits:adminAddress:recipientAddress:isAmountNative:)``.
  ///   - walletSalt: The salt from ``RainEIP712Message/salt``, unchanged.
  ///   - walletSignature: The wallet's hex signature over ``RainEIP712Message/message``.
  public func buildWithdrawTransactionData(
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    executorSignature: RainAdminSignature,
    walletSalt: Data,
    walletSignature: String
  ) throws -> String {
    try WithdrawalBuilder.buildWithdrawTransactionData(
      builder: transactionBuilder,
      addresses: addresses,
      amount: amount,
      decimals: decimals,
      executorSignature: executorSignature,
      walletSalt: walletSalt,
      walletSignature: walletSignature
    )
  }

  /// Composes Rain-owned transaction parameters. Rain-owned so the public surface does not leak
  /// Portal/Turnkey types.
  public func buildTransactionParameters(
    walletAddress: String,
    contractAddress: String,
    transactionData: String
  ) -> RainTransactionParameters {
    RainTransactionParameters(
      from: walletAddress,
      to: contractAddress,
      value: 0.ethToWei.toHexString,
      data: transactionData
    )
  }

  /// Registers additional tokens so their metadata resolves without an on-chain lookup.
  public func registerTokens(_ tokens: [TokenInfo]) {
    Task { await tokenStore.register(tokens) }
  }

  // MARK: - Rain API (issuing)

  /// True once an Api-Key and userId have been supplied (builder or ``configureRainApi(apiKey:userId:)``).
  public var isRainApiConfigured: Bool { rainApiConfig.isConfigured }

  /// Sets or replaces the Rain program Api-Key and userId at runtime. The cached client
  /// session token is discarded lazily — the next API call re-mints against the new pair.
  /// The SDK never persists these values.
  public func configureRainApi(apiKey: String, userId: String) {
    rainApiConfig.setCredentials(apiKey: apiKey, userId: userId)
  }

  /// Fetches the user's collateral contracts (`GET /v1/issuing/users/{userId}/contracts`).
  ///
  /// Token `name`/`symbol`/`decimals` are enriched from the SDK token store (registry,
  /// host-registered tokens, or an on-chain read) — best-effort, a failed lookup leaves them
  /// nil. Needs no wallet provider, only the configured Api-Key/userId and RPC endpoints.
  ///
  /// - Throws: `RainSDKError.rainApiNotConfigured` when no credentials were supplied.
  public func fetchCollateralContracts() async throws -> [RainCollateralContract] {
    try await rainApiService.fetchCollateralContracts()
  }

  /// Convenience for the common single-contract case: the first collateral contract.
  ///
  /// - Throws: `RainSDKError.noCollateralContracts` when the user has none.
  public func fetchCollateralContract() async throws -> RainCollateralContract {
    guard let first = try await fetchCollateralContracts().first else {
      throw RainSDKError.noCollateralContracts
    }
    return first
  }

  /// Fetches the admin withdrawal signature
  /// (`GET /v1/issuing/users/{userId}/signatures/withdrawals`) that authorizes a
  /// ``RainClient/withdrawCollateral(chainId:addresses:amount:decimals:adminSignature:nonce:)`` call.
  ///
  /// - Parameters:
  ///   - amountBaseUnits: Withdrawal amount in the token's base units.
  ///   - adminAddress: One of the contract's ``RainCollateralContract/adminAddresses``.
  /// - Throws: `RainSDKError.signatureNotReady` when Rain has not produced the signature yet —
  ///   retry after the carried `retryAfter` seconds.
  public func fetchAdminSignature(
    chainId: Int,
    tokenAddress: String,
    amountBaseUnits: BigUInt,
    adminAddress: String,
    recipientAddress: String,
    isAmountNative: Bool = true
  ) async throws -> RainAdminSignature {
    try await rainApiService.fetchAdminSignature(
      chainId: chainId,
      tokenAddress: tokenAddress,
      amountBaseUnits: String(amountBaseUnits),
      adminAddress: adminAddress,
      recipientAddress: recipientAddress,
      isAmountNative: isAmountNative
    )
  }

  static func parseISO8601(_ string: String) -> Date? {
    let withFraction = ISO8601DateFormatter()
    withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = withFraction.date(from: string) { return date }
    return ISO8601DateFormatter().date(from: string)
  }

  // MARK: - Builder

  /// Returns a new builder. Register RPC endpoints and provider descriptors, then `build()`.
  public static func builder() -> Builder { Builder() }

  /// Fluent builder for `RainSdk`.
  public final class Builder {
    private var networkConfigs: [NetworkConfig] = []
    private var descriptors: [ProviderId: RainProvider] = [:]
    private var registrationOrder: [ProviderId] = []
    private var registeredTokens: [TokenInfo] = []
    private var rainApiEnvironment: RainApiEnvironment = .dev
    private var rainApiCredentials: (apiKey: String, userId: String)?

    public init() {}

    /// Sets the network configurations (chain id + RPC URL). Required.
    @discardableResult
    public func rpcEndpoints(_ configs: [NetworkConfig]) -> Builder {
      networkConfigs = configs
      return self
    }

    /// Sets RPC endpoints from a `[chainId: rpcUrl]` map.
    @discardableResult
    public func rpcEndpoints(_ map: [Int: String]) -> Builder {
      networkConfigs = map.map { NetworkConfig(chainId: $0.key, rpcUrl: $0.value) }
      return self
    }

    /// Registers a provider descriptor, keyed by its `id`. Re-registering an id replaces it.
    @discardableResult
    public func register(_ provider: any RainProvider) -> Builder {
      if descriptors[provider.id] == nil {
        registrationOrder.append(provider.id)
      }
      descriptors[provider.id] = provider
      return self
    }

    /// Seeds the token store with token metadata.
    @discardableResult
    public func registerTokens(_ tokens: [TokenInfo]) -> Builder {
      registeredTokens.append(contentsOf: tokens)
      return self
    }

    /// Selects the Rain issuing API environment. Defaults to ``RainApiEnvironment/dev``.
    @discardableResult
    public func rainApiEnvironment(_ environment: RainApiEnvironment) -> Builder {
      rainApiEnvironment = environment
      return self
    }

    /// Optionally supplies the Rain program Api-Key and userId at build time — same effect
    /// as calling ``RainSdk/configureRainApi(apiKey:userId:)`` on the built instance.
    @discardableResult
    public func rainApiCredentials(apiKey: String, userId: String) -> Builder {
      rainApiCredentials = (apiKey: apiKey, userId: userId)
      return self
    }

    /// Validates configuration and builds the `RainSdk`.
    ///
    /// At least one RPC endpoint is required. Providers are optional: building with none yields a
    /// **wallet-agnostic** `RainSdk` — the transaction-building methods (`buildEIP712Message`,
    /// `buildWithdrawTransactionData`, `buildTransactionParameters`) work, while `provider(_:)` /
    /// `first(where:)` will throw until a provider is registered.
    /// - Throws: `RainSDKError.invalidConfig` if no/invalid RPC endpoints were provided.
    public func build() throws -> RainSdk {
      guard !networkConfigs.isEmpty else {
        throw RainSDKError.invalidConfig(details: "At least one RPC endpoint is required")
      }
      for config in networkConfigs {
        guard config.chainId > 0, config.rpcUrl.isValidHTTPURL() else {
          throw RainSDKError.invalidConfig(
            details: "Invalid RPC endpoint for chainId \(config.chainId): \(config.rpcUrl)"
          )
        }
      }
      guard rainApiEnvironment.baseURL.absoluteString.isValidHTTPURL() else {
        throw RainSDKError.invalidConfig(
          details: "Invalid Rain API base URL: \(rainApiEnvironment.baseURL.absoluteString)"
        )
      }
      return RainSdk(
        networkConfigs: networkConfigs,
        descriptors: descriptors,
        registrationOrder: registrationOrder,
        registeredTokens: registeredTokens,
        rainApiEnvironment: rainApiEnvironment,
        initialRainApiCredentials: rainApiCredentials
      )
    }
  }
}
