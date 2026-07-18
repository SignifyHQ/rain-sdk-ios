import Foundation
import Web3
import Web3Core

/// Entry point and provider registry for the Rain SDK.
///
/// Built via ``RainSdk/builder()``: register RPC endpoints, one or more provider descriptors, and
/// optional tokens, then `build()`. Resolve a wallet-bound ``RainClient`` by id (`provider(_:)`)
/// or by capability (`first { }`). The registry is designed for the multi-provider case; a
/// single-provider app is simply the trivial `N = 1` instance of it — mirrors Android's `RainSdk`.
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
  // compare on failure eviction. Mirrors Android resolving the whole create under `mutex.withLock`.
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
        let walletProvider: any RainWalletProvider
        do {
          walletProvider = try await descriptors[id]!.create(context: providerContext)
        } catch {
          throw RainSDKError.from(underlying: error)
        }
        return RainSdkManager(
          walletProvider: walletProvider,
          networkConfigs: networkConfigs,
          transactionBuilder: transactionBuilder,
          tokenStore: tokenStore
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

  /// Builds an EIP-712 message (and its salt) for the admin signature required for withdrawals.
  public func buildEIP712Message(
    chainId: Int,
    walletAddress: String,
    assetAddresses: EIP712AssetAddresses,
    amount: Decimal,
    decimals: Int,
    nonce: BigUInt?
  ) async throws -> (String, String) {
    let salt = transactionBuilder.generateSalt()
    let saltHex = "0x" + salt.toHexString()

    let finalNonce: BigUInt
    if let providedNonce = nonce {
      finalNonce = providedNonce
    } else {
      finalNonce = try await transactionBuilder.getLatestNonce(
        proxyAddress: assetAddresses.proxyAddress,
        chainId: chainId
      )
    }

    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    let jsonMessage = try transactionBuilder.buildEIP712Message(
      chainId: chainId,
      collateralProxyAddress: assetAddresses.proxyAddress,
      walletAddress: walletAddress,
      tokenAddress: assetAddresses.tokenAddress,
      amount: amountBaseUnits,
      recipientAddress: assetAddresses.recipientAddress,
      nonce: finalNonce,
      salt: saltHex
    )
    return (jsonMessage, saltHex)
  }

  /// Builds the encoded withdrawal calldata for the collateral proxy contract.
  public func buildWithdrawTransactionData(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Decimal,
    decimals: Int,
    expiresAt: String,
    salt: Data,
    signatureData: Data,
    adminSalt: Data,
    adminSignature: Data
  ) async throws -> String {
    guard let ethereumContractAddress = Web3Core.EthereumAddress(assetAddresses.contractAddress),
          let ethereumProxyAddress = Web3Core.EthereumAddress(assetAddresses.proxyAddress),
          let ethereumTokenAddress = Web3Core.EthereumAddress(assetAddresses.tokenAddress),
          let ethereumRecipientAddress = Web3Core.EthereumAddress(assetAddresses.recipientAddress)
    else {
      throw RainSDKError.internalLogicError(
        details: "Error building transaction parameters for withdrawal. One of the addresses could not be built"
      )
    }

    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)

    let unixTimestamp: Int
    if let timestamp = Int(expiresAt) {
      unixTimestamp = timestamp
    } else if let date = Self.parseISO8601(expiresAt) {
      unixTimestamp = Int(date.timeIntervalSince1970)
    } else {
      throw RainSDKError.internalLogicError(
        details: "Invalid expiration timestamp format. Expected ISO8601 or Unix timestamp string"
      )
    }

    let withdrawAssetParameter = WithdrawAssetParameter(
      proxyAddress: ethereumProxyAddress,
      tokenAddress: ethereumTokenAddress,
      amount: amountBaseUnits,
      recipientAddress: ethereumRecipientAddress,
      expiryAt: BigUInt(unixTimestamp),
      salt: salt,
      signature: signatureData,
      adminSalt: adminSalt,
      adminSignature: adminSignature
    )

    return try await transactionBuilder.buildErc20TransactionForWithdrawAsset(
      chainId: chainId,
      ethereumContractAddress: ethereumContractAddress,
      withdrawAssetParameter: withdrawAssetParameter
    )
  }

  /// Composes Rain-owned transaction parameters. Rain-owned so the public surface does not leak
  /// Portal/Turnkey types (parity with Android).
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
  /// ``RainClient/withdrawCollateral(chainId:assetAddresses:amount:decimals:salt:signature:expiresAt:nonce:)`` call.
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

  /// Fluent builder for `RainSdk`. Mirrors Android's `RainSdk.builder()`.
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

    /// Sets RPC endpoints from a `[chainId: rpcUrl]` map (parity with Android's `rpcEndpoints`).
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
        throw RainSDKError.invalidConfig(chainId: 0, rpcUrl: "")
      }
      for config in networkConfigs {
        guard config.chainId > 0, config.rpcUrl.isValidHTTPURL() else {
          throw RainSDKError.invalidConfig(chainId: config.chainId, rpcUrl: config.rpcUrl)
        }
      }
      guard rainApiEnvironment.baseURL.absoluteString.isValidHTTPURL() else {
        throw RainSDKError.invalidConfig(chainId: 0, rpcUrl: rainApiEnvironment.baseURL.absoluteString)
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
