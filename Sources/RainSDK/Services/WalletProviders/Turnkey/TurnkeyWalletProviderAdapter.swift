import Foundation
import TurnkeyHttp
import TurnkeySwift
import TurnkeyTypes
import Web3

/// Turnkey-based implementation of `RainWalletProvider`.
/// Used when the SDK is initialized with `initializeTurnkey(...)`.
internal final class TurnkeyWalletProviderAdapter: RainWalletProvider, RainTypedDataSignerProvider, RainTransactionFeeEstimatingProvider, RainSolanaTransfersProvider, @unchecked Sendable {
  private enum AdapterConstants {
    static let defaultNativeDecimals = 18
    static let defaultPollingAttempts = 30
    static let pollingIntervalNanoseconds: UInt64 = 1_000_000_000
    /// Turnkey returns a status id, not a Solana signature, so the signature is read back from
    /// the chain as a defensive fallback when the status response carries none.
    static let solanaSignatureLookupAttempts = 8
  }

  private struct ActivityDraft: Sendable {
    let id: String
    let timestamp: TimeInterval
    let from: String
    let to: String
    let value: String?
    let data: String?
    let chainId: Int
    let sendTransactionStatusId: String?
  }

  private let turnkey: TurnkeyContextProtocol
  private let transactionBuilder: TransactionBuilderProtocol?
  private let networkConfigsByChainId: [Int: NetworkConfig]
  private let walletAddressOverride: String?
  private let jsonRpcClient: JsonRpcClient
  private let chainReader: ChainReader
  private let solanaChainReader: ChainReader
  private let solanaRpcClient: SolanaRpcClient
  private let tokenStore: TokenMetadataStore

  // Once resolved, each address is stable for the adapter's lifetime, so cache it. EVM and
  // Solana accounts are cached independently — a Solana request never reads the EVM address.
  private var cachedAddress: String?
  private var cachedSolanaAddress: String?
  private let cachedAddressLock = NSLock()

  internal init(
    turnkey: TurnkeyContextProtocol,
    transactionBuilder: TransactionBuilderProtocol? = nil,
    networkConfigs: [NetworkConfig],
    walletAddress: String? = nil,
    jsonRpcClient: JsonRpcClient = JsonRpcClient(),
    chainReader: ChainReader? = nil,
    solanaChainReader: ChainReader? = nil,
    solanaRpcClient: SolanaRpcClient? = nil,
    tokenStore: TokenMetadataStore? = nil
  ) {
    self.turnkey = turnkey
    self.transactionBuilder = transactionBuilder
    self.networkConfigsByChainId = Dictionary(uniqueKeysWithValues: networkConfigs.map { ($0.chainId, $0) })
    self.walletAddressOverride = walletAddress
    self.jsonRpcClient = jsonRpcClient
    let resolvedReader = chainReader ?? EVMChainReader(
      jsonRpcClient: jsonRpcClient,
      networkConfigs: networkConfigs
    )
    self.chainReader = resolvedReader
    let resolvedSolanaRpcClient = solanaRpcClient
      ?? SolanaRpcClient(jsonRpcClient: jsonRpcClient, networkConfigs: networkConfigs)
    self.solanaRpcClient = resolvedSolanaRpcClient
    self.solanaChainReader = solanaChainReader
      ?? SolanaChainReader(solanaRpcClient: resolvedSolanaRpcClient)
    self.tokenStore = tokenStore ?? TokenMetadataStore(chainReader: resolvedReader)
  }

  /// The reader for `chainId`'s chain family — the Solana reader for Solana clusters, the
  /// EVM reader otherwise.
  private func chainReaderFor(chainId: Int) -> ChainReader {
    SolanaChains.isSolana(chainId) ? solanaChainReader : chainReader
  }

  /// CAIP-2 for `chainId`: EIP-155 for EVM, genesis-hash form for Solana clusters.
  private func caip2For(chainId: Int) -> String {
    ChainIDFormat.namespace(for: chainId).format(chainId: chainId)
  }

  /// True when Turnkey's `get-balances` API covers this chain (EVM allowlist or any Solana
  /// cluster). On any other chain, balance reads fall through to the injected `ChainReader`.
  private func usesTurnkeyForBalances(chainId: Int) -> Bool {
    Constants.turnkeySupportedChains.contains(chainId) || SolanaChains.isSolana(chainId)
  }

  public func address() async throws -> String {
    if let walletAddressOverride, !walletAddressOverride.isEmpty {
      return walletAddressOverride
    }

    if let cached = cachedAddressLock.withLock({ cachedAddress }) {
      return cached
    }

    if let walletAddress = resolveEthereumWalletAddress(from: turnkey.wallets) {
      storeCachedAddress(walletAddress)
      return walletAddress
    }

    try await turnkey.refreshWallets()

    if let walletAddress = resolveEthereumWalletAddress(from: turnkey.wallets) {
      storeCachedAddress(walletAddress)
      return walletAddress
    }

    throw RainSDKError.walletUnavailable
  }

  private func storeCachedAddress(_ address: String) {
    cachedAddressLock.withLock { cachedAddress = address }
  }

  /// Chain-aware address. Solana chains resolve the Turnkey Solana account (base58, ed25519);
  /// every other chain shares the Ethereum account. Internal balance / send paths use this so
  /// a Solana request never reads or signs with the EVM address.
  public func getAddress(chainId: Int) async throws -> String {
    SolanaChains.isSolana(chainId) ? try await solanaAddress() : try await address()
  }

  private func solanaAddress() async throws -> String {
    // The `walletAddress` override is an EVM address, so it never applies to Solana.
    if let cached = cachedAddressLock.withLock({ cachedSolanaAddress }) {
      return cached
    }

    if let walletAddress = resolveSolanaWalletAddress(from: turnkey.wallets) {
      cachedAddressLock.withLock { cachedSolanaAddress = walletAddress }
      return walletAddress
    }

    try await turnkey.refreshWallets()

    if let walletAddress = resolveSolanaWalletAddress(from: turnkey.wallets) {
      cachedAddressLock.withLock { cachedSolanaAddress = walletAddress }
      return walletAddress
    }

    throw RainSDKError.walletUnavailable
  }

  private func resolveSolanaWalletAddress(from wallets: [Wallet]) -> String? {
    wallets
      .flatMap(\.accounts)
      .first(where: { $0.addressFormat == .address_format_solana })?
      .address
  }

  public func sendTransaction(
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> String {
    let (session, client) = try resolveSessionAndClient()
    let sendInput = try await buildTurnkeySendTransactionBody(
      session: session,
      chainId: chainId,
      params: params
    )
    let response = try await client.ethSendTransaction(sendInput)

    return try await pollForTransactionHash(
      client: client,
      organizationId: session.organizationId,
      sendTransactionStatusId: response.sendTransactionStatusId
    )
  }

  public func getBalance(
    chainId: Int,
    token: Token
  ) async throws -> Balance {
    let walletAddress = try await getAddress(chainId: chainId)

    // Solana has its own balance policy (Turnkey-first with an RPC fallback for native SOL),
    // so it branches out before the EVM logic below.
    if SolanaChains.isSolana(chainId) {
      return try await solanaBalance(chainId: chainId, walletAddress: walletAddress, token: token)
    }

    switch token {
    case .contract(let address):
      // `eth_call balanceOf` is the same operation everywhere — delegate to the chain
      // reader so the SDK has one implementation rather than per-adapter copies.
      let info = await tokenStore.tokenInfo(chainId: chainId, address: address)
      return try await chainReaderFor(chainId: chainId).getBalance(
        chainId: chainId,
        walletAddress: walletAddress,
        token: token,
        tokenInfo: info
      )
    case .native:
      if !usesTurnkeyForBalances(chainId: chainId) {
        return try await chainReaderFor(chainId: chainId).getBalance(
          chainId: chainId,
          walletAddress: walletAddress,
          token: .native,
          tokenInfo: nil
        )
      }
      let balances = try await fetchBalances(chainId: chainId, walletAddress: walletAddress)
      return await nativeBalance(
        chainId: chainId,
        from: balances,
        caip2: caip2For(chainId: chainId)
      )
    }
  }

  /// Solana balance read. Turnkey is the primary source; native SOL falls back to the Solana
  /// RPC reader if the Turnkey call fails (the RPC reader can't read SPL, so contract tokens
  /// surface the original error instead of falling back).
  private func solanaBalance(
    chainId: Int,
    walletAddress: String,
    token: Token
  ) async throws -> Balance {
    do {
      let balances = try await fetchBalances(chainId: chainId, walletAddress: walletAddress)
      let caip2 = caip2For(chainId: chainId)
      switch token {
      case .native:
        return await nativeBalance(chainId: chainId, from: balances, caip2: caip2)
      case .contract(let mint):
        return await splBalance(chainId: chainId, from: balances, caip2: caip2, mint: mint)
      }
    } catch {
      guard case .native = token else { throw error }
      return try await chainReaderFor(chainId: chainId).getBalance(
        chainId: chainId,
        walletAddress: walletAddress,
        token: .native,
        tokenInfo: nil
      )
    }
  }

  /// Builds an SPL `Balance` for `mint` from a Turnkey asset list. Turnkey omits zero balances,
  /// so a missing mint yields a zero balance with whatever metadata we can recover.
  private func splBalance(
    chainId: Int,
    from balances: [v1AssetBalance],
    caip2: String,
    mint: String
  ) async -> Balance {
    let asset = balances.first(where: { tokenAddress(from: $0.caip19 ?? "", caip2: caip2) == mint })
    let raw = BigUInt(asset?.balance ?? "0") ?? 0
    return await contractBalanceFrom(chainId: chainId, tokenAddress: mint, raw: raw, balance: asset)
  }

  public func getBalances(
    chainId: Int
  ) async throws -> [Balance] {
    let walletAddress = try await getAddress(chainId: chainId)

    if !usesTurnkeyForBalances(chainId: chainId) {
      let tokens = await tokenStore.registeredTokens(for: chainId)
      let all = try await chainReaderFor(chainId: chainId).getBalances(
        chainId: chainId,
        walletAddress: walletAddress,
        tokens: tokens
      )
      return all.filter { balance in
        if case .native = balance.token { return true }
        return balance.rawAmount > 0
      }
    }

    let caip2 = caip2For(chainId: chainId)
    let balances: [v1AssetBalance]
    if SolanaChains.isSolana(chainId) {
      do {
        balances = try await fetchBalances(chainId: chainId, walletAddress: walletAddress)
      } catch {
        // RPC fallback: SolanaChainReader.getBalances returns native SOL only.
        let all = try await chainReaderFor(chainId: chainId).getBalances(
          chainId: chainId,
          walletAddress: walletAddress,
          tokens: []
        )
        return all.filter { balance in
          if case .native = balance.token { return true }
          return balance.rawAmount > 0
        }
      }
    } else {
      balances = try await fetchBalances(chainId: chainId, walletAddress: walletAddress)
    }

    var output: [Balance] = [await nativeBalance(chainId: chainId, from: balances, caip2: caip2)]
    for balance in balances {
      guard let caip19 = balance.caip19,
            let tokenAddress = tokenAddress(from: caip19, caip2: caip2)
      else {
        continue
      }
      let raw = BigUInt(balance.balance ?? "0") ?? 0
      guard raw > 0 else { continue }
      output.append(
        await contractBalanceFrom(chainId: chainId, tokenAddress: tokenAddress, raw: raw, balance: balance)
      )
    }
    return output
  }

  /// Builds a contract-token `Balance` from a Turnkey asset entry. EVM tokens are enriched via
  /// `tokenStore` (registry / on-chain `decimals()`+`symbol()`) with Turnkey's values taking
  /// precedence; Solana SPL tokens use Turnkey's metadata directly, since the Solana reader
  /// can't enrich and would only cache misleading defaults.
  private func contractBalanceFrom(
    chainId: Int,
    tokenAddress: String,
    raw: BigUInt,
    balance: v1AssetBalance?
  ) async -> Balance {
    if SolanaChains.isSolana(chainId) {
      return Balance(
        token: .contract(address: tokenAddress),
        chainId: chainId,
        rawAmount: raw,
        decimals: balance?.decimals ?? 0,
        symbol: balance?.symbol,
        name: balance?.name
      )
    }
    let info = await tokenStore.tokenInfo(chainId: chainId, address: tokenAddress)
    return Balance(
      token: .contract(address: tokenAddress),
      chainId: chainId,
      rawAmount: raw,
      decimals: balance?.decimals ?? info.decimals,
      symbol: balance?.symbol ?? info.symbol,
      name: balance?.name ?? info.name
    )
  }

  /// Builds the native `Balance` from a Turnkey asset list. Turnkey reports balances in raw
  /// base units, so the string is parsed directly as `BigUInt` (no decimal reconstruction).
  private func nativeBalance(
    chainId: Int,
    from balances: [v1AssetBalance],
    caip2: String
  ) async -> Balance {
    let nativeAsset = balances.first(where: { isNativeAsset($0, caip2: caip2) })
    let raw = BigUInt(nativeAsset?.balance ?? "0") ?? 0
    let native = await tokenStore.nativeCurrency(for: chainId)
    return Balance(
      token: .native,
      chainId: chainId,
      rawAmount: raw,
      decimals: nativeAsset?.decimals ?? native.decimals,
      symbol: native.symbol,
      name: native.name
    )
  }

  public func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction] {
    if SolanaChains.isSolana(chainId) {
      return try await getSolanaTransactions(chainId: chainId, limit: limit, offset: offset, order: order)
    }
    let (session, client) = try resolveSessionAndClient()
    let requestedLimit = min(max((limit ?? 10) + (offset ?? 0), 1), 100)
    let activitiesResponse = try await client.getActivities(
      TGetActivitiesBody(
        organizationId: session.organizationId,
        filterByType: [.activity_type_eth_send_transaction],
        paginationOptions: v1Pagination(limit: String(requestedLimit))
      )
    )

    let matchingDrafts = activitiesResponse.activities.compactMap { activity in
      draftTransaction(from: activity, expectedChainId: chainId)
    }

    let sortedDrafts = matchingDrafts.sorted { lhs, rhs in
      switch order ?? .DESC {
      case .ASC:
        return lhs.timestamp < rhs.timestamp
      case .DESC:
        return lhs.timestamp > rhs.timestamp
      }
    }

    let slicedDrafts = Array(
      sortedDrafts
        .dropFirst(offset ?? 0)
        .prefix(limit ?? sortedDrafts.count)
    )

    var transactions: [WalletTransaction] = []
    transactions.reserveCapacity(slicedDrafts.count)

    for draft in slicedDrafts {
      let txHash = try? await resolveTransactionHash(
        client: client,
        organizationId: session.organizationId,
        sendTransactionStatusId: draft.sendTransactionStatusId
      )

      transactions.append(
        WalletTransaction(
          blockNum: "",
          uniqueId: draft.id,
          hash: txHash ?? draft.id,
          from: draft.from,
          to: draft.to,
          value: decimalStringToDouble(
            balance: draft.value,
            decimals: Self.AdapterConstants.defaultNativeDecimals
          ),
          erc721TokenId: nil,
          erc1155Metadata: nil,
          tokenId: nil,
          asset: nil,
          category: "external",
          rawContract: draft.data.flatMap { data in
            guard data != "0x" && !data.isEmpty else { return nil }
            return WalletTransaction.RawContract(
              value: nil,
              address: draft.to,
              decimal: nil
            )
          },
          metadata: WalletTransaction.Metadata(
            blockTimestamp: Self.iso8601String(from: draft.timestamp)
          ),
          chainId: draft.chainId
        )
      )
    }

    return transactions
  }

  private struct SolanaActivityDraft: Sendable {
    let id: String
    let timestamp: TimeInterval
    let from: String
    let to: String?
    let lamports: UInt64?
    let sendTransactionStatusId: String?
  }

  /// Solana transaction history, sourced from Turnkey activities
  /// (`ACTIVITY_TYPE_SOL_SEND_TRANSACTION`) for consistency with the EVM path — so it shows
  /// only transactions this wallet sent through Turnkey (no receives). Turnkey's Solana
  /// activity carries only the unsigned transaction (no recipient/amount) and no on-chain
  /// signature, so `to`/`value` are decoded from that blob and the row's hash is the Turnkey
  /// status id (not an explorer-resolvable signature).
  private func getSolanaTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction] {
    let (session, client) = try resolveSessionAndClient()
    let caip2 = caip2For(chainId: chainId)
    let requestedLimit = min(max((limit ?? 10) + (offset ?? 0), 1), 100)
    let activitiesResponse = try await client.getActivities(
      TGetActivitiesBody(
        organizationId: session.organizationId,
        filterByType: [.activity_type_sol_send_transaction],
        paginationOptions: v1Pagination(limit: String(requestedLimit))
      )
    )

    let drafts: [SolanaActivityDraft] = activitiesResponse.activities.compactMap { activity in
      guard let intent = activity.intent.solSendTransactionIntent,
            intent.caip2 == caip2 else {
        return nil
      }
      let seconds = Double(activity.createdAt.seconds) ?? 0
      let nanos = Double(activity.createdAt.nanos) ?? 0
      let transfer = SolanaTransactionDecoder.decodeTransfer(intent.unsignedTransaction)
      return SolanaActivityDraft(
        id: activity.id,
        timestamp: seconds + nanos / 1_000_000_000,
        from: intent.signWith,
        to: transfer?.to,
        lamports: transfer?.lamports,
        sendTransactionStatusId: activity.result.solSendTransactionResult?.sendTransactionStatusId
      )
    }

    let sortedDrafts = drafts.sorted { lhs, rhs in
      switch order ?? .DESC {
      case .ASC: return lhs.timestamp < rhs.timestamp
      case .DESC: return lhs.timestamp > rhs.timestamp
      }
    }

    let slicedDrafts = Array(
      sortedDrafts
        .dropFirst(offset ?? 0)
        .prefix(limit ?? sortedDrafts.count)
    )

    let symbol = SolanaChains.nativeCurrency.symbol
    return slicedDrafts.map { draft in
      WalletTransaction(
        blockNum: "",
        uniqueId: draft.id,
        hash: draft.sendTransactionStatusId ?? draft.id,
        from: draft.from,
        to: draft.to,
        value: draft.lamports.map { SolanaConverter.lamportsToSolDouble($0) },
        erc721TokenId: nil,
        erc1155Metadata: nil,
        tokenId: nil,
        asset: symbol,
        category: "external",
        rawContract: nil,
        metadata: WalletTransaction.Metadata(
          blockTimestamp: Self.iso8601String(from: draft.timestamp)
        ),
        chainId: chainId
      )
    }
  }

  // MARK: - Solana send

  func sendSolanaNative(
    chainId: Int,
    to toAddress: String,
    amount: Double
  ) async throws -> String {
    let from = try await getAddress(chainId: chainId)
    let (session, client) = try resolveSessionAndClient()

    let blockhash = try await solanaRpcClient.getLatestBlockhash(chainId: chainId)
    let lamports = try SolanaConverter.solToLamports(amount)
    // The Turnkey type documents `unsignedTransaction` as base64, but the live API hex-decodes
    // it (see SolanaTransactionBuilder). Send hex.
    let unsignedTransaction = try SolanaTransactionBuilder.buildTransferHex(
      from: from,
      to: toAddress,
      lamports: lamports,
      recentBlockhash: blockhash
    )

    let response = try await client.solSendTransaction(
      TSolSendTransactionBody(
        organizationId: session.organizationId,
        caip2: caip2For(chainId: chainId),
        recentBlockhash: blockhash,
        signWith: from,
        sponsor: false,
        unsignedTransaction: unsignedTransaction
      )
    )
    let statusId = response.sendTransactionStatusId

    // The Turnkey SDK returns the Solana signature in the send-status response once Included.
    if let signature = try await pollForSolanaCompletion(
      client: client,
      organizationId: session.organizationId,
      sendTransactionStatusId: statusId
    ) {
      return signature
    }

    // Defensive fallback: recover the signature from chain. `getSignaturesForAddress` lags
    // broadcast slightly, so retry briefly before falling back to the status id.
    for attempt in 0..<AdapterConstants.solanaSignatureLookupAttempts {
      if let signature = try await solanaRpcClient.getLatestSignature(chainId: chainId, address: from) {
        return signature
      }
      if attempt + 1 < AdapterConstants.solanaSignatureLookupAttempts {
        try await Task.sleep(nanoseconds: AdapterConstants.pollingIntervalNanoseconds)
      }
    }
    return statusId
  }

  /// Polls Turnkey for the terminal status of a Solana submission. Returns `solana.signature`
  /// (populated once the tx is Included), `nil` at a terminal status without it or on timeout
  /// (caller then recovers the signature from chain), and throws on explicit failure.
  private func pollForSolanaCompletion(
    client: any TurnkeyClientProtocol,
    organizationId: String,
    sendTransactionStatusId: String
  ) async throws -> String? {
    for attempt in 0..<AdapterConstants.defaultPollingAttempts {
      let status = try await client.getSendTransactionStatus(
        TGetSendTransactionStatusBody(
          organizationId: organizationId,
          sendTransactionStatusId: sendTransactionStatusId
        )
      )

      let normalized = status.txStatus.uppercased()
      if normalized.contains("FAILED") || normalized.contains("REJECTED")
        || status.txError != nil || status.error?.message != nil
      {
        let message = status.txError
          ?? status.error?.message
          ?? "Turnkey Solana transaction submission failed"
        throw RainSDKError.providerError(
          underlying: NSError(
            domain: "TurnkeyTransaction",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: message]
          )
        )
      }

      if let signature = status.solana?.signature, !signature.isEmpty {
        return signature
      }

      // Terminal status but no signature yet: stop; the caller recovers it from chain.
      if normalized.contains("INCLUDED") || normalized.contains("CONFIRMED")
        || normalized.contains("FINALIZED") || normalized.contains("MINED")
      {
        return nil
      }

      if attempt + 1 < AdapterConstants.defaultPollingAttempts {
        try await Task.sleep(nanoseconds: AdapterConstants.pollingIntervalNanoseconds)
      }
    }
    return nil
  }

  func signTypedData(
    chainId: Int,
    walletAddress: String,
    typedData: String
  ) async throws -> String {
    let signature = try await turnkey.signRawPayload(
      signWith: walletAddress,
      payload: typedData,
      encoding: .payload_encoding_eip712,
      hashFunction: .hash_function_no_op
    )

    return Self.ethereumSignatureHex(from: signature)
  }

  func estimateTransactionFee(
    chainId: Int,
    walletAddress: String,
    params: WalletTransactionParams
  ) async throws -> Double {
    let estimateHex = try await rpcCallForHex(
      chainId: chainId,
      method: "eth_estimateGas",
      params: [rpcTransactionObject(from: params)]
    )
    let gasPriceHex = try await rpcCallForHex(
      chainId: chainId,
      method: "eth_gasPrice",
      params: []
    )

    let gasLimit = EthereumConverter.parseHexToDouble(estimateHex, decimals: 0)
    let gasPriceWei = EthereumConverter.parseHexToDouble(gasPriceHex, decimals: 0)

    return gasLimit * gasPriceWei.weiToEth
  }

  private func resolveSessionAndClient() throws -> (Session, any TurnkeyClientProtocol) {
    guard let session = turnkey.session else {
      throw TurnkeySwiftError.invalidSession
    }

    guard let client = turnkey.turnkeyClient else {
      throw TurnkeySwiftError.invalidSession
    }

    return (session, client)
  }

  private func fetchBalances(
    chainId: Int,
    walletAddress: String
  ) async throws -> [v1AssetBalance] {
    let (session, client) = try resolveSessionAndClient()
    let response = try await client.getWalletAddressBalances(
      TGetWalletAddressBalancesBody(
        organizationId: session.organizationId,
        address: walletAddress,
        caip2: caip2For(chainId: chainId)
      )
    )

    return response.balances ?? []
  }

  private func buildTurnkeySendTransactionBody(
    session: Session,
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> TEthSendTransactionBody {
    let nonceHex = try await rpcCallForHex(
      chainId: chainId,
      method: "eth_getTransactionCount",
      params: [params.from, "pending"]
    )
    let estimateGasHex = try await rpcCallForHex(
      chainId: chainId,
      method: "eth_estimateGas",
      params: [rpcTransactionObject(from: params)]
    )
    let gasPriceHex = try await rpcCallForHex(
      chainId: chainId,
      method: "eth_gasPrice",
      params: []
    )

    let nonce = decimalString(fromHex: nonceHex)
    let estimatedGas = BigUInt(decimalString(fromHex: estimateGasHex)) ?? BigUInt(21_000)
    let bufferedGasLimit = estimatedGas + (estimatedGas / 5)
    let gasLimit = (bufferedGasLimit == 0 ? estimatedGas : bufferedGasLimit).description
    let gasPrice = decimalString(fromHex: gasPriceHex)

    return TEthSendTransactionBody(
      organizationId: session.organizationId,
      caip2: ChainIDFormat.EIP155.format(chainId: chainId),
      data: normalizedData(params.data),
      from: params.from,
      gasLimit: gasLimit,
      maxFeePerGas: gasPrice,
      maxPriorityFeePerGas: gasPrice,
      nonce: nonce,
      sponsor: false,
      to: params.to,
      value: decimalString(fromHex: params.value)
    )
  }

  private func resolveEthereumWalletAddress(from wallets: [Wallet]) -> String? {
    wallets
      .flatMap(\.accounts)
      .first(where: { $0.addressFormat == .address_format_ethereum })?
      .address
  }

  private func draftTransaction(
    from activity: v1Activity,
    expectedChainId: Int
  ) -> ActivityDraft? {
    guard let intent = activity.intent.ethSendTransactionIntent else {
      return nil
    }

    let chainId = chainId(from: intent.caip2)
    guard chainId == expectedChainId else {
      return nil
    }

    let seconds = Double(activity.createdAt.seconds) ?? 0
    let nanos = Double(activity.createdAt.nanos) ?? 0

    return ActivityDraft(
      id: activity.id,
      timestamp: seconds + nanos / 1_000_000_000,
      from: intent.from,
      to: intent.to,
      value: intent.value,
      data: intent.data,
      chainId: chainId,
      sendTransactionStatusId: activity.result.ethSendTransactionResult?.sendTransactionStatusId
    )
  }

  private func resolveTransactionHash(
    client: any TurnkeyClientProtocol,
    organizationId: String,
    sendTransactionStatusId: String?
  ) async throws -> String? {
    guard let sendTransactionStatusId else {
      return nil
    }

    let status = try await client.getSendTransactionStatus(
      TGetSendTransactionStatusBody(
        organizationId: organizationId,
        sendTransactionStatusId: sendTransactionStatusId
      )
    )
    return status.eth?.txHash
  }

  private func pollForTransactionHash(
    client: any TurnkeyClientProtocol,
    organizationId: String,
    sendTransactionStatusId: String
  ) async throws -> String {
    for attempt in 0..<Self.AdapterConstants.defaultPollingAttempts {
      let status = try await client.getSendTransactionStatus(
        TGetSendTransactionStatusBody(
          organizationId: organizationId,
          sendTransactionStatusId: sendTransactionStatusId
        )
      )

      if let txHash = status.eth?.txHash, !txHash.isEmpty {
        return txHash
      }

      let normalizedStatus = status.txStatus.uppercased()
      if normalizedStatus.contains("FAILED") || normalizedStatus.contains("REJECTED")
        || status.txError != nil || status.error?.message != nil
      {
        let message = status.txError
          ?? status.error?.message
          ?? "Turnkey transaction submission failed"
        throw RainSDKError.providerError(
          underlying: NSError(
            domain: "TurnkeyTransaction",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: message]
          )
        )
      }

      if attempt + 1 < Self.AdapterConstants.defaultPollingAttempts {
        try await Task.sleep(nanoseconds: Self.AdapterConstants.pollingIntervalNanoseconds)
      }
    }

    throw RainSDKError.internalLogicError(
      details: "Turnkey transaction status polling timed out"
    )
  }

  private func isNativeAsset(_ balance: v1AssetBalance, caip2: String) -> Bool {
    guard let caip19 = balance.caip19 else {
      return false
    }

    return caip19.hasPrefix("\(caip2)/slip44:")
  }

  private func tokenAddress(from caip19: String, caip2: String) -> String? {
    // EVM tokens use the `erc20` asset namespace; Solana SPL tokens use `token`.
    let prefixes = ["\(caip2)/erc20:", "\(caip2)/token:"]
    guard prefixes.contains(where: { caip19.hasPrefix($0) }) else {
      return nil
    }

    let address = String(caip19.split(separator: ":").last ?? "")
    return address.isEmpty ? nil : address
  }

  private func
    chainId(from caip2: String) -> Int {
    Int(caip2.split(separator: ":").last ?? "") ?? 0
  }

  private func rpcCallForHex(
    chainId: Int,
    method: String,
    params: [Any]
  ) async throws -> String {
    let rpcURL = try getRpcURL(chainId: chainId)
    do {
      return try await jsonRpcClient.callForHexResult(rpcUrl: rpcURL, method: method, params: params)
    } catch RainSDKError.invalidRpcUrl(let url) {
      // Upgrade to invalidConfig with the chainId we have on hand.
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: url)
    }
  }

  private func rpcTransactionObject(from params: WalletTransactionParams) -> [String: Any] {
    var transaction: [String: Any] = [
      "from": params.from,
      "to": params.to,
      "value": params.value
    ]

    if !params.data.isEmpty {
      transaction["data"] = params.data
    }

    return transaction
  }

  private func getRpcURL(chainId: Int) throws -> String {
    guard let networkConfig = networkConfigsByChainId[chainId] else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: "")
    }

    return networkConfig.rpcUrl
  }

  private func decimalStringToDouble(
    balance: String?,
    decimals: Int
  ) -> Double {
    guard let balance, !balance.isEmpty else {
      return 0
    }

    let value = NSDecimalNumber(string: balance)
    let divisor = NSDecimalNumber(
      mantissa: 1,
      exponent: Int16(decimals),
      isNegative: false
    )

    return value.dividing(by: divisor).doubleValue
  }

  private func decimalString(fromHex hex: String) -> String {
    guard let value = BigUInt(hex.strippingHexPrefix, radix: 16) else {
      return "0"
    }

    return value.description
  }

  private func normalizedData(_ data: String) -> String {
    if data.isEmpty {
      return "0x"
    }

    return data
  }

  private static func iso8601String(from timestamp: TimeInterval) -> String {
    ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: timestamp))
  }

  private static func ethereumSignatureHex(from signature: SignRawPayloadResult) -> String {
    let r = normalizeHexComponent(signature.r, length: 64)
    let s = normalizeHexComponent(signature.s, length: 64)
    let v = String(format: "%02x", normalizedRecoveryId(signature.v))

    return "0x\(r)\(s)\(v)"
  }

  private static func normalizeHexComponent(_ value: String, length: Int) -> String {
    let clean = value
      .lowercased()
      .replacingOccurrences(of: "0x", with: "")
    if clean.count >= length {
      return String(clean.suffix(length))
    }

    return String(repeating: "0", count: length - clean.count) + clean
  }

  private static func normalizedRecoveryId(_ value: String) -> Int {
    let clean = value.lowercased()
    let parsedValue: Int?

    if clean.hasPrefix("0x") {
      parsedValue = Int(clean.dropFirst(2), radix: 16)
    } else if let decimal = Int(clean) {
      parsedValue = decimal
    } else {
      parsedValue = Int(clean, radix: 16)
    }

    guard let parsedValue else {
      return 27
    }

    return parsedValue >= 27 ? parsedValue : parsedValue + 27
  }
}
