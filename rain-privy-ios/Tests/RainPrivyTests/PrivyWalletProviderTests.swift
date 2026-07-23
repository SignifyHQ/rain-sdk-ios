import Testing
import Foundation
import PrivySDK
import RainCore
@testable import RainPrivy

/// Wallet coverage: balance fault tolerance, zero-balance filtering, fee math, empty history,
/// and the send path (eth_call pre-simulation → switch → broadcast). The JSON-RPC read path runs
/// through a URLProtocol-stubbed `URLSession`, with one stub host per test so parallel tests
/// don't share handlers.
@Suite("Privy Wallet Provider Tests")
struct PrivyWalletProviderTests {
  private static let chainId = 31337
  private static let wallet = "0x000000000000000000000000000000000000dEaD"

  private static func tokens() -> [TokenInfo] {
    [
      TokenInfo(chainId: chainId, address: "0xUSDC", symbol: "USDC", decimals: 6, name: "USD Coin"),
      TokenInfo(chainId: chainId, address: "0xBAD", symbol: "BAD", decimals: 18, name: "Bad"),
      TokenInfo(chainId: chainId, address: "0xZERO", symbol: "ZERO", decimals: 18, name: "Zero"),
    ]
  }

  /// Builds a provider whose RPC reads hit the stub registered for `host` and whose address is a
  /// fixed override (so the Privy source is never consulted for reads).
  private static func makeProvider(
    host: String,
    manager: PrivyManager = PrivyManager(source: FakeWalletSource(wallets: nil)),
    seedTokens: [TokenInfo] = tokens()
  ) async throws -> PrivyWalletProvider {
    let rpcUrl = "https://\(host)/"
    let store = try await TestTokenStore.make(chainId: chainId, rpcUrl: rpcUrl, tokens: seedTokens)
    return PrivyWalletProvider(
      manager: manager,
      rpcEndpoints: [chainId: rpcUrl],
      tokenStore: store,
      walletAddressOverride: wallet,
      rpcClient: PrivyRpcClient(session: StubURLProtocol.makeSession())
    )
  }

  // MARK: - Balances

  @Test("getBalances keeps native and healthy tokens when one token read fails, drops zero balances")
  func balancesFaultTolerantAndZeroFiltered() async throws {
    let host = "balances-ft.rpc"
    StubURLProtocol.setHandler(host: host) { body in
      switch body["method"] as? String {
      case "eth_getBalance":
        return RpcStub.result("0x1")
      case "eth_call":
        switch RpcStub.callTarget(body) {
        case "0xUSDC": return RpcStub.result("0x5")
        case "0xZERO": return RpcStub.result("0x0")
        default: return RpcStub.error(code: -32000, message: "rpc down for this token")
        }
      default:
        return RpcStub.error(code: -32601, message: "unexpected method")
      }
    }

    let provider = try await Self.makeProvider(host: host)
    let balances = try await provider.getBalances(chainId: Self.chainId)

    // Native + the non-zero USDC only; the failing token is dropped (not fatal), zero filtered.
    #expect(balances.map(\.token) == [.native, .contract(address: "0xUSDC")])
    #expect(balances[1].rawAmount.description == "5")
  }

  @Test("getBalances propagates a native balance failure")
  func nativeFailurePropagates() async throws {
    let host = "balances-native-fail.rpc"
    StubURLProtocol.setHandler(host: host) { _ in
      RpcStub.error(code: -32000, message: "node down")
    }

    let provider = try await Self.makeProvider(host: host)
    await #expect(throws: RainSDKError.self) {
      _ = try await provider.getBalances(chainId: Self.chainId)
    }
  }

  @Test("getBalance native reads eth_getBalance with exact wei precision")
  func nativeBalanceExact() async throws {
    let host = "balance-native.rpc"
    StubURLProtocol.setHandler(host: host) { body in
      body["method"] as? String == "eth_getBalance"
        ? RpcStub.result("0x0de0b6b3a7640000") // 1 ETH in wei
        : RpcStub.error(code: -32601, message: "unexpected method")
    }

    let provider = try await Self.makeProvider(host: host)
    let balance = try await provider.getBalance(chainId: Self.chainId, token: .native)

    #expect(balance.token == .native)
    #expect(balance.rawAmount.description == "1000000000000000000")
  }

  @Test("getBalance contract resolves registered metadata")
  func contractBalanceMetadata() async throws {
    let host = "balance-contract.rpc"
    StubURLProtocol.setHandler(host: host) { body in
      body["method"] as? String == "eth_call"
        ? RpcStub.result("0xf4240") // 1_000_000 base units
        : RpcStub.error(code: -32601, message: "unexpected method")
    }

    let provider = try await Self.makeProvider(host: host)
    let balance = try await provider.getBalance(
      chainId: Self.chainId, token: .contract(address: "0xUSDC"))

    #expect(balance.rawAmount.description == "1000000")
    #expect(balance.decimals == 6)
    #expect(balance.symbol == "USDC")
  }

  // MARK: - Fees

  @Test("estimateTransactionFee multiplies gas limit by gas price")
  func feeEstimateMath() async throws {
    let host = "fee.rpc"
    StubURLProtocol.setHandler(host: host) { body in
      switch body["method"] as? String {
      case "eth_estimateGas": return RpcStub.result("0x5208")     // 21000
      case "eth_gasPrice": return RpcStub.result("0x3b9aca00")    // 1 gwei
      default: return RpcStub.error(code: -32601, message: "unexpected method")
      }
    }

    let provider = try await Self.makeProvider(host: host)
    let fee = try await provider.estimateTransactionFee(
      chainId: Self.chainId,
      walletAddress: Self.wallet,
      params: WalletTransactionParams(from: Self.wallet, to: "0xTO", value: "0x0", data: "0x")
    )

    // 21000 * 1e9 wei = 2.1e13 wei = exactly 0.000021 ETH
    #expect(fee == Decimal(string: "0.000021"))
  }

  // MARK: - Send path

  @Test("sendTransaction simulates via eth_call, then switches chain and broadcasts")
  func sendSimulatesThenBroadcasts() async throws {
    let host = "send-happy.rpc"
    StubURLProtocol.setHandler(host: host) { body in
      body["method"] as? String == "eth_call"
        ? RpcStub.result("0x")
        : RpcStub.error(code: -32601, message: "unexpected method")
    }

    let signer = FakeSigner(address: Self.wallet, requestResult: .success("0xHASH"))
    let manager = PrivyManager(source: FakeWalletSource(wallets: [signer]))
    let provider = try await Self.makeProvider(host: host, manager: manager)

    let hash = try await provider.sendTransaction(
      chainId: Self.chainId,
      params: WalletTransactionParams(from: Self.wallet, to: "0xTO", value: "0x1", data: "0x")
    )

    #expect(hash == "0xHASH")
    #expect(signer.events == ["switch:\(Self.chainId)", "request:eth_sendTransaction"])
  }

  @Test("a failing eth_call simulation surfaces as transactionSimulationFailed without broadcasting")
  func simulationFailureBlocksBroadcast() async throws {
    let host = "send-sim-fail.rpc"
    StubURLProtocol.setHandler(host: host) { _ in
      RpcStub.error(code: 3, message: "execution reverted")
    }

    let signer = FakeSigner(address: Self.wallet)
    let manager = PrivyManager(source: FakeWalletSource(wallets: [signer]))
    let provider = try await Self.makeProvider(host: host, manager: manager)

    await #expect(throws: RainSDKError.transactionSimulationFailed(underlying: NSError(domain: "", code: 0))) {
      _ = try await provider.sendTransaction(
        chainId: Self.chainId,
        params: WalletTransactionParams(from: Self.wallet, to: "0xTO", value: "0x1", data: "0x")
      )
    }
    #expect(signer.events.isEmpty) // nothing was broadcast
  }

  // MARK: - History / config

  /// A chain id Privy's transaction indexer supports. Sepolia specifically: it has no entries in
  /// RainCore's default token registry, so `registeredTokens` is exactly what a test seeds.
  private static let indexedChainId = 11_155_111

  /// Builds a provider around `signer` for transaction-history tests, with `tokens` seeded into
  /// the token store (each registered token adds a token-filter history query). History never
  /// touches the RPC client, so it is inert.
  private static func makeHistoryProvider(
    signer: FakeSigner,
    tokens: [TokenInfo] = []
  ) async throws -> PrivyWalletProvider {
    let rpcUrl = "https://history-unused.rpc/"
    let store = try await TestTokenStore.make(chainId: indexedChainId, rpcUrl: rpcUrl, tokens: tokens)
    return PrivyWalletProvider(
      manager: PrivyManager(source: FakeWalletSource(wallets: [signer])),
      rpcEndpoints: [indexedChainId: rpcUrl],
      tokenStore: store,
      rpcClient: PrivyRpcClient(session: StubURLProtocol.makeSession())
    )
  }

  // privyTransactionId defaults to nil so fixtures dedupe by their distinct hashes.
  private static func indexedTransaction(
    hash: String? = "0xHASH",
    createdAt: Int = 1_700_000_000_000,
    status: String = "confirmed",
    privyTransactionId: String? = nil,
    details: PrivyIndexedTransaction.Details? = indexedDetails()
  ) -> PrivyIndexedTransaction {
    PrivyIndexedTransaction(
      caip2: "eip155:1",
      transactionHash: hash,
      userOperationHash: nil,
      status: status,
      createdAt: createdAt,
      sponsored: false,
      privyTransactionId: privyTransactionId,
      walletId: "wallet-id",
      details: details
    )
  }

  private static func indexedDetails(
    asset: String = "eth",
    rawValue: String = "1500000000000000000",
    rawValueDecimals: Int = 18
  ) -> PrivyIndexedTransaction.Details {
    PrivyIndexedTransaction.Details(
      type: "transferSent",
      sender: wallet,
      recipient: "0x1111111111111111111111111111111111111111",
      asset: asset,
      rawValue: rawValue,
      rawValueDecimals: rawValueDecimals,
      displayValues: [:]
    )
  }

  @Test("getTransactions returns empty for a chain Privy does not index without calling Privy")
  func historyUnsupportedChainEmpty() async throws {
    let signer = FakeSigner(address: Self.wallet)
    let provider = try await Self.makeProvider(
      host: "history-unsupported.rpc",
      manager: PrivyManager(source: FakeWalletSource(wallets: [signer]))
    )
    // 31337 is not a chain Privy indexes.
    let transactions = try await provider.getTransactions(
      chainId: Self.chainId, limit: nil, offset: nil, order: nil)
    #expect(transactions.isEmpty)
    #expect(signer.events.isEmpty)
  }

  @Test("getTransactions maps Privy transactions onto the Rain model")
  func historyMapsFields() async throws {
    let signer = FakeSigner(address: Self.wallet)
    signer.transactionsResults = [
      .success(PrivyTransactionsPage(
        transactions: [Self.indexedTransaction(privyTransactionId: "privy-tx-id")],
        nextCursor: nil
      ))
    ]

    let provider = try await Self.makeHistoryProvider(signer: signer)
    let transactions = try await provider.getTransactions(
      chainId: Self.indexedChainId, limit: nil, offset: nil, order: nil)

    let tx = try #require(transactions.first)
    #expect(transactions.count == 1)
    #expect(tx.hash == "0xHASH")
    #expect(tx.uniqueId == "privy-tx-id")
    #expect(tx.from == Self.wallet)
    #expect(tx.to == "0x1111111111111111111111111111111111111111")
    #expect(tx.value == 1.5)
    #expect(tx.asset == "eth")
    #expect(tx.category == "external")
    #expect(tx.rawContract == nil)
    #expect(tx.chainId == Self.indexedChainId)
    #expect(tx.metadata?.blockTimestamp == "2023-11-14T22:13:20Z")
  }

  @Test("getTransactions routes a contract-address asset into rawContract as erc20")
  func historyTokenTransfer() async throws {
    let contract = "0x2222222222222222222222222222222222222222"
    let signer = FakeSigner(address: Self.wallet)
    signer.transactionsResults = [
      .success(PrivyTransactionsPage(
        transactions: [
          Self.indexedTransaction(
            details: Self.indexedDetails(asset: contract, rawValue: "1500000", rawValueDecimals: 6))
        ],
        nextCursor: nil
      ))
    ]

    let provider = try await Self.makeHistoryProvider(signer: signer)
    let transactions = try await provider.getTransactions(
      chainId: Self.indexedChainId, limit: nil, offset: nil, order: nil)

    let tx = try #require(transactions.first)
    #expect(tx.asset == nil)
    #expect(tx.category == "erc20")
    #expect(tx.rawContract == RainCore.WalletTransaction.RawContract(
      value: "1500000", address: contract, decimal: "6"))
    #expect(tx.value == 1.5)
  }

  @Test("getTransactions falls back through userOperationHash and privyTransactionId for pending rows")
  func historyPendingHashFallback() async throws {
    let signer = FakeSigner(address: Self.wallet)
    signer.transactionsResults = [
      .success(PrivyTransactionsPage(
        transactions: [
          Self.indexedTransaction(hash: nil, status: "pending", privyTransactionId: "privy-tx-9")
        ],
        nextCursor: nil
      ))
    ]

    let provider = try await Self.makeHistoryProvider(signer: signer)
    let transactions = try await provider.getTransactions(
      chainId: Self.indexedChainId, limit: nil, offset: nil, order: nil)

    let tx = try #require(transactions.first)
    #expect(tx.hash == "privy-tx-9")
  }

  @Test("getTransactions follows the cursor until offset plus limit rows are collected, then slices")
  func historyCursorPaging() async throws {
    let signer = FakeSigner(address: Self.wallet)
    signer.transactionsResults = [
      .success(PrivyTransactionsPage(
        transactions: (0..<3).map { Self.indexedTransaction(hash: "0xA\($0)", createdAt: 5_000 - $0) },
        nextCursor: "cursor-1"
      )),
      .success(PrivyTransactionsPage(
        transactions: (0..<2).map { Self.indexedTransaction(hash: "0xB\($0)", createdAt: 2_000 - $0) },
        nextCursor: "cursor-2"
      )),
    ]

    let provider = try await Self.makeHistoryProvider(signer: signer)
    let transactions = try await provider.getTransactions(
      chainId: Self.indexedChainId, limit: 3, offset: 2, order: nil)

    // Needs 5 rows: page one (3 rows, limit 5) then page two via cursor (2 rows, limit 2).
    #expect(signer.events == [
      "getTransactions:chain=sepolia,assets=eth,tokens=nil,limit=5,cursor=nil",
      "getTransactions:chain=sepolia,assets=eth,tokens=nil,limit=2,cursor=cursor-1",
    ])
    // Newest-first by default; offset 2 drops the two newest, limit 3 keeps the rest.
    #expect(transactions.map(\.hash) == ["0xA2", "0xB0", "0xB1"])
  }

  @Test("getTransactions stops paging when history is exhausted and honors ASC order")
  func historyAscOrder() async throws {
    let signer = FakeSigner(address: Self.wallet)
    signer.transactionsResults = [
      .success(PrivyTransactionsPage(
        transactions: [
          Self.indexedTransaction(hash: "0xNEW", createdAt: 2_000),
          Self.indexedTransaction(hash: "0xOLD", createdAt: 1_000),
        ],
        nextCursor: nil
      ))
    ]

    let provider = try await Self.makeHistoryProvider(signer: signer)
    let transactions = try await provider.getTransactions(
      chainId: Self.indexedChainId, limit: 10, offset: nil, order: .ASC)

    #expect(signer.events.count == 1)
    #expect(transactions.map(\.hash) == ["0xOLD", "0xNEW"])
  }

  @Test("getTransactions propagates Privy failures")
  func historyErrorPropagates() async throws {
    struct IndexerDown: Error {}
    let signer = FakeSigner(address: Self.wallet)
    signer.transactionsResults = [.failure(IndexerDown())]

    let provider = try await Self.makeHistoryProvider(signer: signer)
    await #expect(throws: IndexerDown.self) {
      _ = try await provider.getTransactions(
        chainId: Self.indexedChainId, limit: nil, offset: nil, order: nil)
    }
  }

  @Test("getTransactions merges native and registered-token history and dedupes overlapping rows")
  func historyMergesTokenQueries() async throws {
    let contract = "0x2222222222222222222222222222222222222222"
    let signer = FakeSigner(address: Self.wallet)
    signer.transactionsResults = [
      .success(PrivyTransactionsPage(
        transactions: [Self.indexedTransaction(hash: "0xNATIVE", createdAt: 3_000)],
        nextCursor: nil
      )),
      .success(PrivyTransactionsPage(
        transactions: [
          Self.indexedTransaction(hash: "0xTOKEN", createdAt: 2_000),
          Self.indexedTransaction(hash: "0xNATIVE", createdAt: 3_000),
        ],
        nextCursor: nil
      )),
    ]

    let usdc = TokenInfo(
      chainId: Self.indexedChainId, address: contract, symbol: "USDC", decimals: 6, name: "USD Coin")
    let provider = try await Self.makeHistoryProvider(signer: signer, tokens: [usdc])
    let transactions = try await provider.getTransactions(
      chainId: Self.indexedChainId, limit: nil, offset: nil, order: nil)

    // One native-asset query plus one token-address query; the duplicate row appears once.
    #expect(signer.events == [
      "getTransactions:chain=sepolia,assets=eth,tokens=nil,limit=10,cursor=nil",
      "getTransactions:chain=sepolia,assets=nil,tokens=\(contract),limit=10,cursor=nil",
    ])
    #expect(transactions.map(\.hash) == ["0xNATIVE", "0xTOKEN"])
  }

  @Test("getTransactions fails the whole call when a token query fails instead of returning partial history")
  func historyTokenQueryFailureFailsCall() async throws {
    // The raw error bubbles up (like the native query) so `RainSDKError.from` classifies it via
    // the registered PrivyErrorMapping at the SDK boundary; no partial rows are returned.
    struct TokenFilterRejected: Error {}
    let contract = "0x2222222222222222222222222222222222222222"
    let signer = FakeSigner(address: Self.wallet)
    signer.transactionsResults = [
      .success(PrivyTransactionsPage(
        transactions: [Self.indexedTransaction(hash: "0xNATIVE")],
        nextCursor: nil
      )),
      .failure(TokenFilterRejected()),
    ]

    let usdc = TokenInfo(
      chainId: Self.indexedChainId, address: contract, symbol: "USDC", decimals: 6, name: "USD Coin")
    let provider = try await Self.makeHistoryProvider(signer: signer, tokens: [usdc])
    await #expect(throws: TokenFilterRejected.self) {
      _ = try await provider.getTransactions(
        chainId: Self.indexedChainId, limit: nil, offset: nil, order: nil)
    }
  }

  @Test("getTransactions surfaces a not-logged-in Privy session as tokenExpired")
  func historyNotLoggedInSurfacesTokenExpired() async throws {
    // `PrivySDK.PrivyError` has no public initializer, so the not-logged-in case is exercised
    // through the manager's wallet resolution, which throws the same `.tokenExpired` that
    // PrivyErrorMapping produces for authenticationFailure(.notLoggedIn).
    let rpcUrl = "https://history-not-logged-in.rpc/"
    let store = try await TestTokenStore.make(chainId: Self.indexedChainId, rpcUrl: rpcUrl, tokens: [])
    let provider = PrivyWalletProvider(
      manager: PrivyManager(source: FakeWalletSource(wallets: nil)),
      rpcEndpoints: [Self.indexedChainId: rpcUrl],
      tokenStore: store,
      rpcClient: PrivyRpcClient(session: StubURLProtocol.makeSession())
    )

    await #expect(throws: RainSDKError.tokenExpired) {
      _ = try await provider.getTransactions(
        chainId: Self.indexedChainId, limit: nil, offset: nil, order: nil)
    }
  }

  @Test("an unconfigured chain id surfaces invalidConfig")
  func missingRpcEndpoint() async throws {
    let provider = try await Self.makeProvider(host: "missing-rpc.rpc")
    await #expect(throws: RainSDKError.invalidConfig(chainId: 999, rpcUrl: "")) {
      _ = try await provider.getBalance(chainId: 999, token: .native)
    }
  }

  @Test("address override is returned without consulting Privy")
  func addressOverride() async throws {
    let source = FakeWalletSource(wallets: nil)
    let provider = try await Self.makeProvider(
      host: "address-override.rpc", manager: PrivyManager(source: source))
    #expect(try await provider.address() == Self.wallet)
    #expect(source.lookups == 0)
  }
}
