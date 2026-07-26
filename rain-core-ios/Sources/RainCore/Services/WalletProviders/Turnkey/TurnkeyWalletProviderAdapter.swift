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
    /// Used when `eth_estimateGas` returns zero or an unparseable value.
    static let fallbackGasLimit = 21_000
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
  private let networkConfigsByChainId: [Int: NetworkConfig]
  private let walletAddressOverride: String?
  private let jsonRpcClient: JsonRpcClient
  private let chainReader: ChainReader
  private let solanaSupport: RainSolanaSupport
  private let tokenStore: TokenMetadataStore

  private var solanaChainReader: ChainReader { solanaSupport.chainReader }
  private var solanaRpcClient: SolanaRpcClient { solanaSupport.solanaRpcClient }
  private var solanaTransferComposer: SolanaTransferComposer { solanaSupport.transferComposer }

  // Once resolved, each address is stable for the adapter's lifetime, so cache it. EVM and
  // Solana accounts are cached independently — a Solana request never reads the EVM address.
  // Resolution is single-flighted: concurrent first callers share one in-flight Task, so
  // `refreshWallets` runs at most once per resolution.
  private var cachedAddress: String?
  private var cachedSolanaAddress: String?
  private var addressResolution: Task<String, Error>?
  private var solanaAddressResolution: Task<String, Error>?
  private let cachedAddressLock = NSLock()

  internal init(
    turnkey: TurnkeyContextProtocol,
    networkConfigs: [NetworkConfig],
    walletAddress: String? = nil,
    jsonRpcClient: JsonRpcClient = JsonRpcClient(),
    chainReader: ChainReader? = nil,
    solanaSupport: RainSolanaSupport? = nil,
    tokenStore: TokenMetadataStore? = nil
  ) {
    self.turnkey = turnkey
    self.networkConfigsByChainId = Dictionary(uniqueKeysWithValues: networkConfigs.map { ($0.chainId, $0) })
    self.walletAddressOverride = walletAddress
    self.jsonRpcClient = jsonRpcClient
    let resolvedReader = chainReader ?? EVMChainReader(
      jsonRpcClient: jsonRpcClient,
      networkConfigs: networkConfigs
    )
    self.chainReader = resolvedReader
    self.solanaSupport = solanaSupport ?? RainSolanaSupport(networkConfigs: networkConfigs)
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
    return try await resolveAddress(cache: \.cachedAddress, inFlight: \.addressResolution) {
      $0.resolveEthereumWalletAddress(from: $0.turnkey.wallets)
    }
  }

  /// Single-flight resolve-once: the cached value wins; otherwise concurrent callers share the
  /// in-flight Task (one wallet refresh). A failed Task is evicted so a later call retries.
  private func resolveAddress(
    cache: ReferenceWritableKeyPath<TurnkeyWalletProviderAdapter, String?>,
    inFlight: ReferenceWritableKeyPath<TurnkeyWalletProviderAdapter, Task<String, Error>?>,
    resolve: @escaping @Sendable (TurnkeyWalletProviderAdapter) -> String?
  ) async throws -> String {
    let task: Task<String, Error> = cachedAddressLock.withLock {
      if let cached = self[keyPath: cache] {
        return Task { cached }
      }
      if let existing = self[keyPath: inFlight] {
        return existing
      }
      let task = Task { [self] in
        if let walletAddress = resolve(self) { return walletAddress }
        try await turnkey.refreshWallets()
        if let walletAddress = resolve(self) { return walletAddress }
        throw RainSDKError.walletUnavailable
      }
      self[keyPath: inFlight] = task
      return task
    }

    do {
      let resolved = try await task.value
      cachedAddressLock.withLock {
        self[keyPath: cache] = resolved
        if self[keyPath: inFlight] == task { self[keyPath: inFlight] = nil }
      }
      return resolved
    } catch {
      cachedAddressLock.withLock {
        if self[keyPath: inFlight] == task { self[keyPath: inFlight] = nil }
      }
      throw error
    }
  }

  /// Chain-aware address. Solana chains resolve the Turnkey Solana account (base58, ed25519);
  /// every other chain shares the Ethereum account. Internal balance / send paths use this so
  /// a Solana request never reads or signs with the EVM address.
  public func getAddress(chainId: Int) async throws -> String {
    SolanaChains.isSolana(chainId) ? try await solanaAddress() : try await address()
  }

  private func solanaAddress() async throws -> String {
    // The `walletAddress` override is an EVM address, so it never applies to Solana.
    try await resolveAddress(cache: \.cachedSolanaAddress, inFlight: \.solanaAddressResolution) {
      $0.resolveSolanaWalletAddress(from: $0.turnkey.wallets)
    }
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
    try requireEVM(chainId: chainId, operation: "sendTransaction")
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

    // Solana has its own balance policy (Turnkey-first with an RPC fallback),
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

  /// Solana balance read. Turnkey is the primary source, with the Solana RPC reader as the
  /// fallback for both native SOL and SPL tokens — Turnkey does not index every cluster (devnet
  /// in particular), and the node always does.
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
        return try await splBalance(
          chainId: chainId,
          walletAddress: walletAddress,
          from: balances,
          caip2: caip2,
          mint: mint
        )
      }
    } catch {
      return try await chainReaderFor(chainId: chainId).getBalance(
        chainId: chainId,
        walletAddress: walletAddress,
        token: token,
        tokenInfo: await solanaTokenInfo(chainId: chainId, token: token)
      )
    }
  }

  /// Host-registered metadata for a mint, if any — the naming source for the chain-fallback
  /// path. Reads only the registry, never `TokenMetadataStore.tokenInfo`, whose enrichment path
  /// goes through the EVM reader and cannot describe an SPL mint.
  private func solanaTokenInfo(chainId: Int, token: Token) async -> TokenInfo? {
    guard case .contract(let mint) = token else { return nil }
    return await tokenStore.registeredTokens(for: chainId)
      .first { $0.address.lowercased() == mint.lowercased() }
  }

  /// Native SOL plus the SPL tokens the wallet holds, read from the node. Zero balances are
  /// dropped, matching every other chain. Naming falls back to host-registered tokens, so a
  /// mint no indexer covers can still be labelled by the caller rather than shown as a bare
  /// address.
  private func solanaBalancesFromNode(
    chainId: Int,
    walletAddress: String
  ) async throws -> [Balance] {
    let all = try await chainReaderFor(chainId: chainId).getBalances(
      chainId: chainId,
      walletAddress: walletAddress,
      tokens: await tokenStore.registeredTokens(for: chainId)
    )
    return all.filter { balance in
      if case .native = balance.token { return true }
      return balance.rawAmount > 0
    }
  }

  /// Builds an SPL `Balance` for `mint` from a Turnkey asset list.
  ///
  /// Turnkey omits zero balances, and on a cluster it does not index every mint looks like a
  /// zero — so a missing entry is re-read from the node rather than reported as zero with
  /// unknown decimals.
  private func splBalance(
    chainId: Int,
    walletAddress: String,
    from balances: [v1AssetBalance],
    caip2: String,
    mint: String
  ) async throws -> Balance {
    guard let asset = balances.first(where: { tokenAddress(from: $0.caip19 ?? "", caip2: caip2) == mint })
    else {
      return try await chainReaderFor(chainId: chainId).getBalance(
        chainId: chainId,
        walletAddress: walletAddress,
        token: .contract(address: mint),
        tokenInfo: await solanaTokenInfo(chainId: chainId, token: .contract(address: mint))
      )
    }
    let raw = BigUInt(asset.balance ?? "0") ?? 0
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
      let turnkeyBalances = try? await fetchBalances(chainId: chainId, walletAddress: walletAddress)
      // Turnkey does not index every cluster: on devnet / testnet it errors, or answers with SOL
      // and no SPL assets at all. Discovering the wallet's token accounts from the node covers
      // both cases; on mainnet, where Turnkey does list SPL assets, its richer metadata wins.
      let listsSplAssets = turnkeyBalances?.contains { balance in
        tokenAddress(from: balance.caip19 ?? "", caip2: caip2) != nil
      } ?? false
      guard let turnkeyBalances, listsSplAssets else {
        return try await solanaBalancesFromNode(chainId: chainId, walletAddress: walletAddress)
      }
      balances = turnkeyBalances
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
    order: RainTransactionOrder?
  ) async throws -> [RainTransaction] {
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

    var transactions: [RainTransaction] = []
    transactions.reserveCapacity(slicedDrafts.count)

    for draft in slicedDrafts {
      let txHash = try? await resolveTransactionHash(
        client: client,
        organizationId: session.organizationId,
        sendTransactionStatusId: draft.sendTransactionStatusId
      )
      // A contract call carries calldata; a plain transfer does not.
      let isContractCall = draft.data.map { $0 != "0x" && !$0.isEmpty } ?? false

      transactions.append(
        RainTransaction(
          hash: txHash ?? draft.id,
          uniqueId: draft.id,
          timestamp: Self.iso8601String(from: draft.timestamp),
          from: draft.from,
          to: draft.to,
          value: decimalStringToDecimal(
            balance: draft.value,
            decimals: Self.AdapterConstants.defaultNativeDecimals
          ),
          tokenAddress: isContractCall ? draft.to : nil,
          rawValue: draft.value,
          decimals: Self.AdapterConstants.defaultNativeDecimals,
          category: .external,
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
    /// Set instead of `lamports` when the activity was an SPL transfer.
    let token: SolanaTransactionDecoder.TokenTransfer?
  }

  /// Solana transaction history, sourced from Turnkey activities
  /// (`ACTIVITY_TYPE_SOL_SEND_TRANSACTION`) for consistency with the EVM path — so it shows only
  /// transactions this wallet sent through Turnkey (no receives). Turnkey's Solana activity carries
  /// only the unsigned transaction (no recipient/amount) and no on-chain signature, so `to`/`value`
  /// are decoded from that blob and the row's hash is the Turnkey status id (not an
  /// explorer-resolvable signature).
  ///
  /// Both shapes Rain sends are decoded: a System transfer becomes a native SOL row, and an SPL
  /// `TransferChecked` a token row carrying the mint in `rawContract`. SPL transfers move between
  /// *token accounts*, so the recipient wallet is recovered from the transaction's
  /// account-creation instruction when it has one, and read from the node otherwise.
  private func getSolanaTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: RainTransactionOrder?
  ) async throws -> [RainTransaction] {
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
      let token = transfer == nil
        ? SolanaTransactionDecoder.decodeTokenTransfer(intent.unsignedTransaction)
        : nil
      return SolanaActivityDraft(
        id: activity.id,
        timestamp: seconds + nanos / 1_000_000_000,
        from: intent.signWith,
        to: transfer?.to ?? token?.destinationOwner ?? token?.destination,
        lamports: transfer?.lamports,
        sendTransactionStatusId: activity.result.solSendTransactionResult?.sendTransactionStatusId,
        token: token
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

    var transactions: [RainTransaction] = []
    transactions.reserveCapacity(slicedDrafts.count)
    for draft in slicedDrafts {
      transactions.append(await solanaTransaction(chainId: chainId, from: draft))
    }
    return transactions
  }

  /// Maps one decoded Solana activity onto the Rain model. SPL rows resolve their decimals and
  /// recipient wallet from the node when the transaction itself didn't carry them; both reads are
  /// best-effort, so a row always lists.
  private func solanaTransaction(
    chainId: Int,
    from draft: SolanaActivityDraft
  ) async -> RainTransaction {
    var value = draft.lamports.map { SolanaConverter.lamportsToSol($0) }
    var asset: String? = SolanaChains.nativeCurrency.symbol
    var category = RainTransactionCategory.external
    var tokenAddress: String?
    var rawValue: String?
    var resolvedDecimals: Int?
    var metadata: RainTransaction.Metadata?
    var to = draft.to

    if let token = draft.token {
      category = .token
      let mint = token.mint
      // TransferChecked carries the decimals; the bare Transfer instruction does not.
      var decimals = token.decimals.map(Int.init)
      if decimals == nil, let mint {
        decimals = try? await solanaRpcClient.getMintInfo(chainId: chainId, mint: mint)?.decimals
      }
      value = decimals.map {
        EthereumConverter.baseUnitsToDecimal(BigUInt(token.rawAmount.description) ?? 0, decimals: $0)
      }
      // Registered metadata only — enrichment reads `decimals()` over EVM RPC, which no mint answers.
      asset = nil
      if let mint {
        asset = await tokenStore.registeredTokens(for: chainId)
          .first { $0.address == mint }?
          .symbol
      }
      tokenAddress = mint
      rawValue = "\(token.rawAmount)"
      resolvedDecimals = decimals
      // The token accounts are not reconstructible from `to`, which holds the wallet when the
      // owner read succeeded and the token account when it didn't.
      metadata = RainTransaction.Metadata(
        sourceTokenAccount: token.source,
        destinationTokenAccount: token.destination
      )
      if token.destinationOwner == nil {
        // Falls back to the token account when the owner cannot be read — a real address the user
        // can look up, rather than nothing.
        let owner = try? await solanaRpcClient.getTokenAccount(
          chainId: chainId, address: token.destination
        )
        to = owner?.owner.isEmpty == false ? owner?.owner : token.destination
      }
    }

    return RainTransaction(
      hash: draft.sendTransactionStatusId ?? draft.id,
      uniqueId: draft.id,
      timestamp: Self.iso8601String(from: draft.timestamp),
      from: draft.from,
      to: to,
      value: value,
      asset: asset,
      tokenAddress: tokenAddress,
      rawValue: rawValue,
      decimals: resolvedDecimals,
      category: category,
      chainId: chainId,
      metadata: metadata
    )
  }

  // MARK: - Solana send

  func sendSolanaNative(
    chainId: Int,
    to toAddress: String,
    amount: Decimal
  ) async throws -> String {
    let from = try await getAddress(chainId: chainId)
    let unsigned = try await solanaTransferComposer.composeNative(
      chainId: chainId, from: from, to: toAddress, amount: amount
    )
    return try await submitSolanaTransaction(chainId: chainId, from: from, unsigned: unsigned)
  }

  /// Signs and broadcasts a transaction core composed (a collateral withdrawal). The bytes are
  /// signed as handed over — rebuilding them would invalidate the coordinator signature they embed.
  func signAndSendSolanaTransaction(
    chainId: Int,
    unsigned: UnsignedSolanaTransfer
  ) async throws -> String {
    let from = try await getAddress(chainId: chainId)
    return try await submitSolanaTransaction(chainId: chainId, from: from, unsigned: unsigned)
  }

  /// Hands a composed transfer to Turnkey (which signs with the wallet's ed25519 key and
  /// broadcasts) and resolves it to a signature. Shared by the native and SPL paths.
  ///
  /// The Turnkey type documents `unsignedTransaction` as base64, but the live API hex-decodes it
  /// (see `SolanaTransactionBuilder`), so the hex form is sent.
  private func submitSolanaTransaction(
    chainId: Int,
    from: String,
    unsigned: UnsignedSolanaTransfer
  ) async throws -> String {
    let (session, client) = try resolveSessionAndClient()

    let response = try await client.solSendTransaction(
      TSolSendTransactionBody(
        organizationId: session.organizationId,
        caip2: caip2For(chainId: chainId),
        recentBlockhash: unsigned.recentBlockhash,
        signWith: from,
        sponsor: false,
        unsignedTransaction: unsigned.transactionHex
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

  // MARK: - SPL token send

  /// Sends SPL tokens. Composition and every preflight (mint resolution, token-account
  /// derivation/creation, balance and fee checks, simulation) live in ``SolanaTransferComposer``;
  /// this method only signs and broadcasts through Turnkey.
  ///
  /// `decimals` is deliberately unread — it is not authoritative here. The composer reads the
  /// mint's own scale from the chain, which `TransferChecked` then enforces.
  func sendSolanaSPLToken(
    chainId: Int,
    mintAddress: String,
    to toAddress: String,
    amount: Decimal,
    decimals: Int
  ) async throws -> String {
    let from = try await getAddress(chainId: chainId)
    let unsigned = try await solanaTransferComposer.composeSPLToken(
      chainId: chainId,
      from: from,
      mintAddress: mintAddress,
      to: toAddress,
      amount: amount
    )
    return try await submitSolanaTransaction(chainId: chainId, from: from, unsigned: unsigned)
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
    try requireEVM(chainId: chainId, operation: "signTypedData")
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
  ) async throws -> Decimal {
    try requireEVM(chainId: chainId, operation: "estimateTransactionFee")
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

    // Exact wei math: multiply as BigUInt, divide to native units as Decimal.
    let gasLimit = try EthereumConverter.parseHexToBigUIntStrict(estimateHex)
    let gasPriceWei = try EthereumConverter.parseHexToBigUIntStrict(gasPriceHex)

    return EthereumConverter.baseUnitsToDecimal(
      gasLimit * gasPriceWei,
      decimals: AdapterConstants.defaultNativeDecimals
    )
  }

  /// Rejects Solana chain ids on the EVM-only paths; Solana transfers go through `sendNative` /
  /// `sendToken`.
  private func requireEVM(chainId: Int, operation: String) throws {
    guard SolanaChains.isSolana(chainId) else { return }
    throw RainSDKError.invalidConfig(
      details: "Turnkey provider does not support \(operation) on Solana; use sendNative for SOL transfers"
    )
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
    // `decimalString(fromHex:)` yields "0" (not nil) for a zero or unparseable estimate, so the
    // fallback has to key off the value, not off a failed conversion.
    let parsedGas = BigUInt(decimalString(fromHex: estimateGasHex)) ?? 0
    let estimatedGas = parsedGas > 0 ? parsedGas : BigUInt(AdapterConstants.fallbackGasLimit)
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
      throw RainSDKError.invalidConfig(details: "Invalid RPC URL for chainId=\(chainId): \(url)")
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
      throw RainSDKError.invalidConfig(details: "No RPC endpoint configured for chainId=\(chainId)")
    }

    return networkConfig.rpcUrl
  }

  private func decimalStringToDecimal(
    balance: String?,
    decimals: Int
  ) -> Decimal {
    guard let balance, !balance.isEmpty else {
      return 0
    }

    let value = NSDecimalNumber(string: balance)
    guard value != NSDecimalNumber.notANumber else {
      return 0
    }
    let divisor = NSDecimalNumber(
      mantissa: 1,
      exponent: Int16(decimals),
      isNegative: false
    )

    return value.dividing(by: divisor).decimalValue
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
