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

    // 21000 * 1e9 wei = 2.1e13 wei = 0.000021 ETH
    #expect(abs(fee - 0.000021) < 1e-12)
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

  @Test("getTransactions returns empty as privy exposes no history")
  func historyEmpty() async throws {
    let provider = try await Self.makeProvider(host: "history.rpc")
    let transactions = try await provider.getTransactions(
      chainId: Self.chainId, limit: nil, offset: nil, order: nil)
    #expect(transactions.isEmpty)
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
