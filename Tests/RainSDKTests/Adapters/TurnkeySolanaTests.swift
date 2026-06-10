import Testing
import Foundation
import TurnkeySwift
import TurnkeyTypes
import Web3
@testable import RainSDK

/// Solana-path tests for the Turnkey adapter, driven through `RainSDKManager`. Stubs that use
/// `MockURLProtocol` run serialized (global registration).
@Suite("Turnkey Solana Adapter Tests", .serialized)
struct TurnkeySolanaTests {
  private static let host = "solana.test"
  private static let rpcUrl = "https://solana.test/rpc"
  private static let chainId = SolanaChains.mainnet // 101
  private static var solanaCaip2: String { SolanaChains.caip2(for: chainId)! }

  private let recipient = Base58.encode((0..<32).map { UInt8($0 + 40) })
  private let blockhash = Base58.encode((0..<32).map { UInt8($0 + 70) })

  private func configs() -> [NetworkConfig] {
    [.testConfig(chainId: Self.chainId, rpcUrl: Self.rpcUrl)]
  }

  private func dualCurveTurnkey() -> MockTurnkey {
    MockTurnkey(wallets: [MockTurnkey.dualCurveWallet()])
  }

  // MARK: - Address resolution

  @Test("getWalletAddress(chainId:) resolves the Solana account for Solana chains")
  func solanaAddress() async throws {
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: dualCurveTurnkey(), configs: configs())
    let address = try await manager.getWalletAddress(chainId: Self.chainId)
    #expect(address == MockTurnkey.defaultSolanaAddress)
  }

  @Test("getWalletAddress(chainId:) still returns the EVM address for EVM chains")
  func evmAddressUnaffected() async throws {
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: dualCurveTurnkey(), configs: configs())
    let address = try await manager.getWalletAddress(chainId: 1)
    #expect(address == MockTurnkey.defaultWalletAddress)
  }

  // MARK: - Send

  @Test("sendNativeToken on Solana returns the signature from the status response")
  func sendSolanaReturnsSignature() async throws {
    let turnkey = dualCurveTurnkey()
    let client = turnkey.turnkeyClient as! MockTurnkeyClient
    client.sendTransactionStatusQueue = [.solanaIncluded(signature: "sol-sig-123")]

    try await MockURLProtocol.withInstalled {
      MockURLProtocol.interceptedHosts = [Self.host]
      MockURLProtocol.stub(method: "getLatestBlockhash", result: ["value": ["blockhash": blockhash]])
      let (manager, _, _) = TestManagers.turnkeyManager(turnkey: turnkey, configs: configs())

      let result = try await manager.sendNativeToken(chainId: Self.chainId, to: recipient, amount: 0.5)
      #expect(result.transactionHash == "sol-sig-123")

      // The unsigned transaction was built and submitted via sol_send_transaction.
      #expect(client.solSendTransactionCalls.count == 1)
      let body = client.solSendTransactionCalls[0]
      #expect(body.caip2 == Self.solanaCaip2)
      #expect(body.signWith == MockTurnkey.defaultSolanaAddress)
      #expect(SolanaTransactionDecoder.decodeTransfer(body.unsignedTransaction)?.to == recipient)
    }
  }

  // MARK: - History

  @Test("getTransactions on Solana decodes sol_send activities")
  func solanaHistory() async throws {
    let turnkey = dualCurveTurnkey()
    let client = turnkey.turnkeyClient as! MockTurnkeyClient
    let unsigned = try SolanaTransactionBuilder.buildTransferHex(
      from: MockTurnkey.defaultSolanaAddress, to: recipient,
      lamports: 1_000_000_000, recentBlockhash: blockhash)
    client.mockActivities = [
      MockTurnkey.makeSolanaActivity(
        id: "act-1",
        signWith: MockTurnkey.defaultSolanaAddress,
        caip2: Self.solanaCaip2,
        unsignedTransaction: unsigned,
        sendTransactionStatusId: "status-1")
    ]
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: turnkey, configs: configs())

    let txs = try await manager.getTransactions(chainId: Self.chainId, limit: nil, offset: nil, order: nil)
    #expect(txs.count == 1)
    #expect(txs[0].hash == "status-1")
    #expect(txs[0].to == recipient)
    #expect(txs[0].from == MockTurnkey.defaultSolanaAddress)
    #expect(txs[0].value == 1.0)
    #expect(txs[0].asset == "SOL")
    #expect(txs[0].chainId == Self.chainId)
    #expect(client.getActivitiesCalls[0].filterByType == [.activity_type_sol_send_transaction])
  }

  // MARK: - Balances

  @Test("getBalance(.native) on Solana reads SOL from Turnkey")
  func solanaNativeBalanceViaTurnkey() async throws {
    let turnkey = dualCurveTurnkey()
    let client = turnkey.turnkeyClient as! MockTurnkeyClient
    client.mockBalances = [
      v1AssetBalance(
        balance: "2000000000",
        caip19: "\(Self.solanaCaip2)/slip44:501",
        decimals: 9,
        name: "Solana",
        symbol: "SOL")
    ]
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: turnkey, configs: configs())

    let balance = try await manager.getBalance(chainId: Self.chainId, token: .native)
    #expect(balance.token == .native)
    #expect(balance.symbol == "SOL")
    #expect(balance.decimals == 9)
    #expect(balance.decimalAmount == 2)
    #expect(client.walletAddressBalanceCalls[0].caip2 == Self.solanaCaip2)
    #expect(client.walletAddressBalanceCalls[0].address == MockTurnkey.defaultSolanaAddress)
  }

  @Test("getBalances on Solana falls back to the RPC reader when Turnkey errors")
  func solanaBalancesRpcFallback() async throws {
    let turnkey = dualCurveTurnkey()
    let client = turnkey.turnkeyClient as! MockTurnkeyClient
    client.walletAddressBalancesError = RainSDKError.providerError(
      underlying: NSError(domain: "test", code: 1))

    try await MockURLProtocol.withInstalled {
      MockURLProtocol.interceptedHosts = [Self.host]
      MockURLProtocol.stub(method: "getBalance", result: ["value": 1_000_000_000])
      let (manager, _, _) = TestManagers.turnkeyManager(turnkey: turnkey, configs: configs())

      let balances = try await manager.getBalances(chainId: Self.chainId)
      #expect(balances.count == 1)
      #expect(balances[0].token == .native)
      #expect(balances[0].symbol == "SOL")
      #expect(balances[0].decimalAmount == 1)
    }
  }

  // MARK: - SPL guard
  //
  // SPL token transfers are wired through `RainSolanaTransfersProvider.sendSolanaSPLToken`
  // but the on-chain message construction is not yet implemented. Until that work lands the
  // adapter throws, and the public `sendToken` API surfaces a clear error.

  @Test("sendToken on Solana throws (SPL not yet implemented)")
  func splSendThrows() async {
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: dualCurveTurnkey(), configs: configs())
    await #expect(throws: RainSDKError.self) {
      _ = try await manager.sendToken(
        chainId: Self.chainId, contractAddress: "mint", to: recipient, amount: 1, decimals: 6)
    }
  }
}
