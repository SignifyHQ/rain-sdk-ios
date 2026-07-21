import Foundation
import PrivySDK
import RainCore
import Web3

/// Privy-backed `RainWalletProvider`.
///
/// Custody (signing, broadcasting) goes through Privy's EIP-1193 embedded wallet via
/// ``PrivyManager``; balance and fee reads run through ``PrivyRpcClient`` against Rain's
/// configured RPC, with metadata resolved by `tokenStore`.
///
/// Transaction history comes from Privy's indexer via the wallet's `getTransactions` (TEE wallets
/// only, and only on chains Privy indexes); unsupported chains return an empty list, matching the
/// pre-indexer behavior.
internal final class PrivyWalletProvider: RainWalletProvider, RainTypedDataSignerProvider, RainTransactionFeeEstimatingProvider, @unchecked Sendable {
  /// Upper bound on simultaneous per-token balance RPC calls in ``getBalances(chainId:)``. Without
  /// it a large token registry would fan out one connection per token at once.
  private static let maxConcurrentBalanceReads = 8

  private let manager: PrivyManager
  private let rpcEndpoints: [Int: String]
  private let tokenStore: TokenMetadataStore
  private let walletAddressOverride: String?
  private let rpcClient: PrivyRpcClient

  internal init(
    manager: PrivyManager,
    rpcEndpoints: [Int: String],
    tokenStore: TokenMetadataStore,
    walletAddressOverride: String? = nil,
    rpcClient: PrivyRpcClient = PrivyRpcClient()
  ) {
    self.manager = manager
    self.rpcEndpoints = rpcEndpoints
    self.tokenStore = tokenStore
    self.walletAddressOverride = walletAddressOverride
    self.rpcClient = rpcClient
  }

  // MARK: - Address

  func address() async throws -> String {
    try await manager.address(override: walletAddressOverride)
  }

  // Privy embedded wallets are Ethereum-only, so `getAddress(chainId:)` inherits the default
  // (returns `address()`).

  // MARK: - Send

  func sendTransaction(
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> String {
    let rpcUrl = try rpcUrl(for: chainId)

    // Simulate via eth_call before broadcasting to catch failures (revert / insufficient funds)
    // up front — the node validates it for free.
    do {
      _ = try await rpcClient.callForHexResult(
        rpcUrl: rpcUrl,
        method: "eth_call",
        params: [rpcTransactionObject(from: params), "latest"]
      )
    } catch {
      if error is CancellationError { throw error }
      throw RainSDKError.transactionSimulationFailed(underlying: error)
    }

    let transaction = EthereumRpcRequest.UnsignedEthTransaction(
      from: params.from,
      to: params.to,
      data: normalizedData(params.data),
      value: .hexadecimalNumber(params.value.isEmpty ? "0x0" : params.value),
      chainId: .int(chainId)
    )

    return try await manager.sendTransaction(
      walletAddress: params.from,
      rpcUrl: rpcUrl,
      chainId: chainId,
      transaction: transaction
    )
  }

  // MARK: - Sign

  func signTypedData(
    chainId: Int,
    walletAddress: String,
    typedData: String
  ) async throws -> String {
    try await manager.signTypedData(walletAddress: walletAddress, typedDataJson: typedData)
  }

  // MARK: - Fees

  func estimateTransactionFee(
    chainId: Int,
    walletAddress: String,
    params: WalletTransactionParams
  ) async throws -> Double {
    let rpcUrl = try rpcUrl(for: chainId)
    let gasLimitHex = try await rpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_estimateGas",
      params: [rpcTransactionObject(from: params)]
    )
    let gasPriceHex = try await rpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_gasPrice",
      params: []
    )
    let gasLimit = EthereumConverter.parseHexToDouble(gasLimitHex, decimals: 0)
    let gasPriceWei = EthereumConverter.parseHexToDouble(gasPriceHex, decimals: 0)
    return gasLimit * gasPriceWei.weiToEth
  }

  // MARK: - Balances

  func getBalance(
    chainId: Int,
    token: Token
  ) async throws -> Balance {
    let walletAddress = try await address()
    switch token {
    case .native:
      return try await fetchNativeBalance(chainId: chainId, walletAddress: walletAddress)
    case .contract(let contractAddress):
      return try await fetchContractBalance(
        chainId: chainId,
        walletAddress: walletAddress,
        address: contractAddress
      )
    }
  }

  func getBalances(
    chainId: Int
  ) async throws -> [Balance] {
    let walletAddress = try await address()

    // Native is essential: its failure propagates. Per-token reads are best-effort — a single
    // bad / failing contract must not drop the whole list, so each is wrapped and skipped on
    // failure. Concurrency is capped by a sliding window over the task group.
    let native = try await fetchNativeBalance(chainId: chainId, walletAddress: walletAddress)
    let tokens = await tokenStore.registeredTokens(for: chainId)

    var output: [Balance] = [native]
    guard !tokens.isEmpty else { return output }

    let contractBalances = await withTaskGroup(of: Balance?.self) { group in
      var nextIndex = 0
      let window = min(Self.maxConcurrentBalanceReads, tokens.count)
      while nextIndex < window {
        let address = tokens[nextIndex].address
        group.addTask { [self] in
          await tryFetchContractBalance(chainId: chainId, walletAddress: walletAddress, address: address)
        }
        nextIndex += 1
      }

      var collected: [Balance] = []
      for await result in group {
        if let balance = result, balance.rawAmount > 0 {
          collected.append(balance)
        }
        if nextIndex < tokens.count {
          let address = tokens[nextIndex].address
          group.addTask { [self] in
            await tryFetchContractBalance(chainId: chainId, walletAddress: walletAddress, address: address)
          }
          nextIndex += 1
        }
      }
      return collected
    }

    output.append(contentsOf: contractBalances)
    return output
  }

  /// Best-effort single contract balance: logs and returns `nil` on failure so one token never
  /// cancels the batch.
  private func tryFetchContractBalance(
    chainId: Int,
    walletAddress: String,
    address: String
  ) async -> Balance? {
    do {
      return try await fetchContractBalance(chainId: chainId, walletAddress: walletAddress, address: address)
    } catch {
      RainLogger.warning("Rain SDK: Privy balance read failed for token=\(address) chainId=\(chainId); skipping: \(error)")
      return nil
    }
  }

  private func fetchNativeBalance(chainId: Int, walletAddress: String) async throws -> Balance {
    let rpcUrl = try rpcUrl(for: chainId)
    let hex = try await rpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_getBalance",
      params: [walletAddress, "latest"]
    )
    let native = await tokenStore.nativeCurrency(for: chainId)
    return Balance(
      token: .native,
      chainId: chainId,
      rawAmount: EthereumConverter.parseHexToBigUInt(hex),
      decimals: native.decimals,
      symbol: native.symbol,
      name: native.name
    )
  }

  private func fetchContractBalance(
    chainId: Int,
    walletAddress: String,
    address: String
  ) async throws -> Balance {
    let rpcUrl = try rpcUrl(for: chainId)
    let info = await tokenStore.tokenInfo(chainId: chainId, address: address)
    let callData = Multicall3.encodeBalanceOf(address: walletAddress)
    let callObject: [String: Any] = ["to": address, "data": callData]
    let hex = try await rpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_call",
      params: [callObject, "latest"]
    )
    return Balance(
      token: .contract(address: address),
      chainId: chainId,
      rawAmount: EthereumConverter.parseHexToBigUInt(hex),
      decimals: info.decimals,
      symbol: info.symbol,
      name: info.name
    )
  }

  // MARK: - Transactions

  /// Default rows returned by `getTransactions` when the caller passes no limit (parity with
  /// Turnkey).
  private static let defaultTransactionLimit = 10
  /// Privy's server-side maximum page size for its transactions endpoint.
  private static let maxTransactionsPageSize = 100
  /// Privy's server-side maximum number of asset/token filters per request.
  private static let maxTransactionFiltersPerRequest = 10

  /// Wallet history from Privy's transaction indexer.
  ///
  /// Privy's endpoint requires exactly one of an `assets` or `tokens` filter per request, so
  /// full history is assembled from one native-asset query plus token-address queries over the
  /// registered tokens (chunked to the server's 10-filter cap). The native query is essential
  /// (its failure propagates); token queries are best-effort, mirroring `getBalances`. Privy
  /// paginates by cursor while the SDK contract is limit/offset, so each query collects pages
  /// until `offset + limit` rows are gathered (or history is exhausted); the merged rows are
  /// deduped, sorted by `createdAt` per `order` (newest first by default, matching Turnkey) and
  /// sliced. Chains Privy does not index (e.g. Base Sepolia) return an empty list rather than
  /// failing, preserving the previous always-empty behavior.
  func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [RainCore.WalletTransaction] {
    guard let chain = Self.privyChain(for: chainId) else {
      return []
    }
    let walletAddress = try await address()
    let needed = max((limit ?? Self.defaultTransactionLimit) + (offset ?? 0), 1)

    var collected = try await collectTransactions(
      walletAddress: walletAddress,
      chain: chain.chain,
      assets: [chain.nativeAsset],
      tokens: nil,
      needed: needed
    )
    let tokenAddresses = await tokenStore.registeredTokens(for: chainId).map(\.address)
    for chunk in Self.chunks(tokenAddresses, size: Self.maxTransactionFiltersPerRequest) {
      do {
        collected += try await collectTransactions(
          walletAddress: walletAddress,
          chain: chain.chain,
          assets: nil,
          tokens: chunk,
          needed: needed
        )
      } catch {
        if error is CancellationError { throw error }
      }
    }

    var seen = Set<String>()
    let deduped = collected.filter { transaction in
      guard let key = transaction.privyTransactionId ?? transaction.transactionHash else { return true }
      return seen.insert(key).inserted
    }
    let sorted = deduped.sorted { lhs, rhs in
      switch order ?? .DESC {
      case .ASC: return lhs.createdAt < rhs.createdAt
      case .DESC: return lhs.createdAt > rhs.createdAt
      }
    }
    let sliced = sorted
      .dropFirst(offset ?? 0)
      .prefix(limit ?? needed)

    return sliced.map { Self.rainTransaction(chainId: chainId, from: $0) }
  }

  /// Collects up to `needed` rows for one assets-or-tokens filter, following Privy's cursor.
  private func collectTransactions(
    walletAddress: String,
    chain: TransactionChain,
    assets: [String]?,
    tokens: [String]?,
    needed: Int
  ) async throws -> [PrivyIndexedTransaction] {
    var collected: [PrivyIndexedTransaction] = []
    var cursor: String?
    repeat {
      let page = try await manager.getTransactions(
        walletAddress: walletAddress,
        params: GetTransactionsParams(
          chain: chain,
          assets: assets,
          tokens: tokens,
          limit: min(needed - collected.count, Self.maxTransactionsPageSize),
          cursor: cursor
        )
      )
      collected.append(contentsOf: page.transactions)
      cursor = page.nextCursor
    } while cursor != nil && collected.count < needed
    return collected
  }

  private static func chunks<T>(_ array: [T], size: Int) -> [[T]] {
    stride(from: 0, to: array.count, by: size).map {
      Array(array[$0..<min($0 + size, array.count)])
    }
  }

  private static func rainTransaction(
    chainId: Int,
    from transaction: PrivyIndexedTransaction
  ) -> RainCore.WalletTransaction {
    let details = transaction.details
    // `asset` is either a named asset ("eth", "usdc") or a token contract address; an address
    // means a token transfer, which carries its contract in `rawContract` like Alchemy's shape.
    let assetIsAddress = details?.asset.hasPrefix("0x") == true
    let value = details.flatMap { detail -> Double? in
      guard let raw = Double(detail.rawValue) else { return nil }
      return raw / pow(10, Double(detail.rawValueDecimals))
    }
    return RainCore.WalletTransaction(
      blockNum: "",
      uniqueId: transaction.privyTransactionId ?? transaction.transactionHash ?? "",
      hash: transaction.transactionHash
        ?? transaction.userOperationHash
        ?? transaction.privyTransactionId
        ?? "",
      from: details?.sender ?? "",
      to: details?.recipient,
      value: value,
      erc721TokenId: nil,
      erc1155Metadata: nil,
      tokenId: nil,
      asset: assetIsAddress ? nil : details?.asset,
      category: assetIsAddress ? "erc20" : "external",
      rawContract: details.flatMap { detail in
        guard assetIsAddress else { return nil }
        return RainCore.WalletTransaction.RawContract(
          value: detail.rawValue,
          address: detail.asset,
          decimal: String(detail.rawValueDecimals)
        )
      },
      metadata: RainCore.WalletTransaction.Metadata(
        blockTimestamp: Date(timeIntervalSince1970: Double(transaction.createdAt) / 1000)
          .formatted(.iso8601)
      ),
      chainId: chainId
    )
  }

  /// The `TransactionChain` and native-asset filter name Privy's indexer accepts for `chainId`,
  /// or `nil` when the chain is not indexed (verified against the endpoint's server-side enum:
  /// ethereum, arbitrum, avalanche, base, bsc, tempo, linea, optimism, polygon, solana, sepolia).
  /// Privy identifies chains by slug, not chain id; when Privy adds a slug with no SDK case yet
  /// (e.g. a testnet), map it here via `TransactionChain.custom(_:)`.
  private static func privyChain(for chainId: Int) -> (chain: TransactionChain, nativeAsset: String)? {
    switch chainId {
    case 1: return (.ethereum, "eth")
    case 10: return (.optimism, "eth")
    case 56: return (.bsc, "bnb")
    case 137: return (.polygon, "pol")
    case 8453: return (.base, "eth")
    case 42161: return (.arbitrum, "eth")
    case 43114: return (.avalanche, "avax")
    case 59144: return (.linea, "eth")
    case 11155111: return (.sepolia, "eth")
    default: return nil
    }
  }

  // MARK: - Helpers

  private func rpcUrl(for chainId: Int) throws -> String {
    guard let rpcUrl = rpcEndpoints[chainId], !rpcUrl.isEmpty else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: "")
    }
    return rpcUrl
  }

  /// Builds an `eth_call` / `eth_estimateGas` transaction object, omitting empty `data`.
  private func rpcTransactionObject(from params: WalletTransactionParams) -> [String: Any] {
    var transaction: [String: Any] = [
      "from": params.from,
      "to": params.to,
      "value": params.value.isEmpty ? "0x0" : params.value
    ]
    if let data = normalizedData(params.data) {
      transaction["data"] = data
    }
    return transaction
  }

  /// Normalizes calldata for Privy: `nil` for an empty / `"0x"` payload, else the hex string.
  private func normalizedData(_ data: String) -> String? {
    (data.isEmpty || data == "0x") ? nil : data
  }
}
