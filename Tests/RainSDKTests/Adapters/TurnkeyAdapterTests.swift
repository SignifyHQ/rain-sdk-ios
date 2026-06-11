import Testing
import Foundation
import TurnkeySwift
import TurnkeyTypes
import Web3
@testable import RainSDK

/// Tests that stub `URLSession.shared` via `MockURLProtocol` run serialized to avoid
/// interfering with each other's stubs (the protocol registration is global).
@Suite("Turnkey Adapter Tests", .serialized)
struct TurnkeyAdapterTests {

  // MARK: - Address resolution

  @Test("getWalletAddress returns address from Turnkey wallet")
  func testGetWalletAddressFromContext() async throws {
    let (manager, _, _) = TestManagers.turnkeyManager()
    let address = try await manager.getWalletAddress()
    #expect(address == MockTurnkey.defaultWalletAddress)
  }

  @Test("getWalletAddress prefers explicit walletAddress override")
  func testGetWalletAddressOverride() async throws {
    let override = "0xover0000000000000000000000000000000000000"
    let (manager, _, _) = TestManagers.turnkeyManager(walletAddress: override)
    let address = try await manager.getWalletAddress()
    #expect(address == override)
  }

  @Test("getWalletAddress refreshes wallets when no eth account is present")
  func testGetWalletAddressRefreshes() async throws {
    let mockTurnkey = MockTurnkey(wallets: [])
    let (manager, turnkey, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getWalletAddress()
    }
    #expect(turnkey.refreshWalletsCallCount == 1)
  }

  // MARK: - Balances

  @Test("getBalance(.native) with Turnkey parses 1 ETH from a single ether balance")
  func testGetNativeBalanceTurnkey() async throws {
    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.mockBalances = [
      v1AssetBalance(
        balance: "1000000000000000000",
        caip19: "eip155:1/slip44:60",
        decimals: 18,
        name: "Ether",
        symbol: "ETH"
      )
    ]
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    let balance = try await manager.getBalance(chainId: 1, token: .native)

    #expect(balance.token == .native)
    #expect(balance.symbol == "ETH")
    #expect(balance.decimalAmount == 1)
    #expect(client.walletAddressBalanceCalls.count == 1)
    #expect(client.walletAddressBalanceCalls[0].caip2 == "eip155:1")
    #expect(client.walletAddressBalanceCalls[0].address == MockTurnkey.defaultWalletAddress)
  }

  @Test("getBalances with Turnkey returns native plus mapped erc20 balances")
  func testGetERC20BalancesTurnkey() async throws {
    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.mockBalances = [
      v1AssetBalance(
        balance: "1000000",
        caip19: "eip155:1/erc20:\(TestFixtures.usdcAddress)",
        decimals: 6,
        name: "USD Coin",
        symbol: "USDC"
      )
    ]
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    let balances = try await manager.getTokenBalances(chainId: 1)

    // Native is always included (at zero here — the mock reports no native asset).
    #expect(balances.count == 2)
    #expect(balances.contains { $0.token == .native })
    let usdc = try #require(balances.first { $0.token == .contract(address: TestFixtures.usdcAddress) })
    #expect(usdc.decimals == 6)
    #expect(usdc.symbol == "USDC")
    #expect(usdc.decimalAmount == 1)
    #expect(client.walletAddressBalanceCalls.count == 1)
  }

  @Test("getBalance(.contract) with Turnkey parses eth_call result via the chain reader")
  func testGetERC20BalanceTurnkey() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    MockURLProtocol.stub(method: "eth_call", result: "0x0F4240") // 1_000_000 (USDC 6dp)

    let (manager, _, _) = TestManagers.turnkeyManager()
    let balance = try await manager.getBalance(
      chainId: 1,
      token: .contract(address: TestFixtures.usdcAddress)
    )

    #expect(balance.decimals == 6)
    #expect(balance.decimalAmount == 1)
    // USDC is in the registry, so no enrichment RPC — only the balanceOf eth_call.
    #expect(MockURLProtocol.recordedMethods == ["eth_call"])
  }

  @Test("getBalance(.contract) with Turnkey maps RPC network failures to networkError")
  func testGetERC20BalanceTurnkeyRpcNetworkError() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    MockURLProtocol.stubError(
      method: "eth_call",
      error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
    )

    let (manager, _, _) = TestManagers.turnkeyManager()

    await #expect(throws: RainSDKError.networkError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.getBalance(
        chainId: 1,
        token: .contract(address: TestFixtures.usdcAddress)
      )
    }
  }

  // MARK: - ChainReader routing (Turnkey-unsupported chains)

  /// Returns an adapter wired with a MockChainReader so we can observe routing decisions
  /// without going through `TestManagers.turnkeyManager` (which constructs its own reader).
  private func makeAdapterWithMockChainReader(
    chainIds: [Int],
    walletAddress: String = MockTurnkey.defaultWalletAddress
  ) -> (TurnkeyWalletProviderAdapter, MockTurnkey, MockChainReader) {
    let configs = chainIds.map { NetworkConfig.testConfig(chainId: $0) }
    let mockTurnkey = MockTurnkey()
    let mockReader = MockChainReader()
    let adapter = TurnkeyWalletProviderAdapter(
      turnkey: mockTurnkey,
      transactionBuilder: MockTransactionBuilderService(networkConfigs: configs),
      networkConfigs: configs,
      walletAddress: walletAddress,
      chainReader: mockReader
    )
    return (adapter, mockTurnkey, mockReader)
  }

  @Test("getBalance(.native) on an unsupported chain routes to the ChainReader")
  func testGetNativeBalanceUnsupportedChainRoutes() async throws {
    let (adapter, mockTurnkey, mockReader) = makeAdapterWithMockChainReader(chainIds: [43114])
    let native = Balance(token: .native, chainId: 43114, rawAmount: BigUInt(7_500_000_000_000_000_000), decimals: 18, symbol: "AVAX")
    mockReader.stubbedSingleBalance = native
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient

    let balance = try await adapter.getBalance(chainId: 43114, token: .native)

    #expect(balance == native)
    #expect(balance.decimalAmount == 7.5)
    #expect(mockReader.getBalanceCalls == [
      MockChainReader.SingleBalanceCall(chainId: 43114, walletAddress: MockTurnkey.defaultWalletAddress, token: .native)
    ])
    // Turnkey's balance API must NOT be hit on an unsupported chain.
    #expect(client.walletAddressBalanceCalls.isEmpty)
  }

  @Test("getBalance(.native) on a supported chain still uses Turnkey's balances API")
  func testGetNativeBalanceSupportedChainUsesTurnkey() async throws {
    let (adapter, mockTurnkey, mockReader) = makeAdapterWithMockChainReader(chainIds: [1])
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.mockBalances = [
      v1AssetBalance(
        balance: "1000000000000000000",
        caip19: "eip155:1/slip44:60",
        decimals: 18,
        name: "Ether",
        symbol: "ETH"
      )
    ]

    let balance = try await adapter.getBalance(chainId: 1, token: .native)

    #expect(balance.token == .native)
    #expect(balance.decimalAmount == 1)
    #expect(client.walletAddressBalanceCalls.count == 1)
    #expect(mockReader.getBalanceCalls.isEmpty)
  }

  @Test("getBalances on an unsupported chain delegates to ChainReader with registry tokens")
  func testGetERC20BalancesUnsupportedChainRoutes() async throws {
    let (adapter, mockTurnkey, mockReader) = makeAdapterWithMockChainReader(chainIds: [43114])
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    let avax = Balance(token: .native, chainId: 43114, rawAmount: BigUInt(2_000_000_000_000_000_000), decimals: 18, symbol: "AVAX", name: "Avalanche")
    let usdc = Balance(token: .contract(address: "0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E"), chainId: 43114, rawAmount: BigUInt(42_000_000), decimals: 6, symbol: "USDC") // 42 USDC (6dp)
    let dai = Balance(token: .contract(address: "0xd586E7F844cEa2F87f50152665BCbc2C279D8d70"), chainId: 43114, rawAmount: BigUInt(17) * BigUInt(1_000_000_000_000_000_000), decimals: 18, symbol: "DAI") // 17 DAI (18dp)
    mockReader.stubbedBalances = [avax, usdc, dai]

    let balances = try await adapter.getBalances(chainId: 43114)

    // Native is kept alongside the two non-zero ERC-20s.
    #expect(balances.count == 3)
    #expect(balances.contains { $0.token == .native })
    #expect(balances.contains(usdc))
    #expect(balances.contains(dai))
    #expect(mockReader.balancesCalls.count == 1)
    // Tokens passed to the reader come from TokenRegistry[43114].
    let expectedAddresses = TokenRegistry.tokens(for: 43114).map(\.address)
    #expect(mockReader.balancesCalls[0].tokenAddresses == expectedAddresses)
    #expect(client.walletAddressBalanceCalls.isEmpty)
  }

  @Test("getBalance(.contract) always routes through ChainReader for unified eth_call handling")
  func testGetERC20BalanceAlwaysUsesChainReader() async throws {
    let (adapter, _, mockReader) = makeAdapterWithMockChainReader(chainIds: [1, 43114])
    mockReader.stubbedSingleBalance = Balance(
      token: .contract(address: TestFixtures.usdcAddress),
      chainId: 1,
      rawAmount: BigUInt(9_990_000),
      decimals: 6,
      symbol: "USDC"
    )

    let mainnet = try await adapter.getBalance(chainId: 1, token: .contract(address: TestFixtures.usdcAddress))
    let avax = try await adapter.getBalance(chainId: 43114, token: .contract(address: TestFixtures.usdcAddress))

    #expect(mainnet.decimalAmount == 9.99)
    #expect(avax.decimalAmount == 9.99)
    #expect(mockReader.getBalanceCalls.count == 2)
  }

  // MARK: - getTransactions

  @Test("getTransactions with Turnkey returns mapped activities")
  func testGetTransactionsTurnkey() async throws {
    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.mockTransactionHash = "0x" + String(repeating: "b", count: 64)
    client.mockActivities = [
      MockTurnkey.makeActivity(
        id: "activity-1",
        from: "0xfrom",
        to: "0xto",
        caip2: "eip155:1",
        value: "1000000000000000000",
        data: "0x",
        sendTransactionStatusId: client.mockSendTransactionStatusId
      )
    ]
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    let list = try await manager.getTransactions(chainId: 1, limit: 10, offset: 0, order: .DESC)

    #expect(list.count == 1)
    #expect(list[0].hash == client.mockTransactionHash)
    #expect(list[0].from == "0xfrom")
    #expect(list[0].to == "0xto")
    #expect(list[0].value == 1.0)
    #expect(list[0].chainId == 1)
    #expect(client.getActivitiesCalls.count == 1)
    #expect(client.sendTransactionStatusCalls.count == 1)
  }

  // MARK: - withdraw signing payload

  @Test("buildTransactionParamForWithdrawAsset uses Turnkey EIP-712 signing")
  func testBuildTransactionParamForWithdrawAssetTurnkey() async throws {
    let (manager, mockTurnkey, builder) = TestManagers.turnkeyManager()
    builder.mockNonce = BigUInt(42)

    let result = try await manager.buildTransactionParamForWithdrawAsset(
      chainId: 1,
      assetAddresses: TestFixtures.defaultWithdrawAddresses,
      amount: 100.0,
      decimals: 18,
      salt: TestFixtures.validSaltBase64,
      signature: TestFixtures.validSignatureHex,
      expiresAt: "1735689600",
      nonce: nil
    )

    #expect(result.walletAddress == MockTurnkey.defaultWalletAddress)
    #expect(result.transactionParams.from == MockTurnkey.defaultWalletAddress)
    #expect(result.transactionParams.to == TestFixtures.contractAddress)
    #expect(result.transactionParams.data.hasPrefix("0x"))
    #expect(mockTurnkey.signRawPayloadCalls.count == 1)

    let signCall = try #require(mockTurnkey.signRawPayloadCalls.first)
    #expect(signCall.signWith == MockTurnkey.defaultWalletAddress)
    #expect(signCall.encoding == .payload_encoding_eip712)
    #expect(signCall.hashFunction == .hash_function_no_op)
    #expect(!signCall.payload.isEmpty)
  }

  // MARK: - signRawPayload failure propagation

  @Test("withdrawCollateral propagates Turnkey sign error")
  func testTurnkeySignFailurePropagates() async throws {
    let mockTurnkey = MockTurnkey()
    mockTurnkey.signRawPayloadError = NSError(
      domain: "Turnkey",
      code: 42,
      userInfo: [NSLocalizedDescriptionKey: "sign failed"]
    )
    let (manager, _, builder) = TestManagers.turnkeyManager(turnkey: mockTurnkey)
    builder.mockNonce = BigUInt(1)

    do {
      _ = try await manager.buildTransactionParamForWithdrawAsset(
        chainId: 1,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600",
        nonce: BigUInt(1)
      )
      Issue.record("Expected Turnkey sign error to propagate")
    } catch let error as NSError {
      #expect(error.domain == "Turnkey")
      #expect(error.code == 42)
    } catch {
      Issue.record("Expected NSError from Turnkey sign error, got \(type(of: error))")
    }
  }

  // MARK: - sendNative / sendToken via Turnkey (URLSession-stubbed)

  @Test("sendNative with Turnkey returns mock tx hash")
  func testSendNativeTokenTurnkey() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    stubSendTransactionRPCs()

    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    let expectedHash = "0x" + String(repeating: "f", count: 64)
    client.sendTransactionStatusQueue = [.broadcasted(hash: expectedHash)]

    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    let result = try await manager.sendNative(
      chainId: 1,
      to: TestFixtures.recipientAddress,
      amount: 1.5
    )

    #expect(result.transactionHash == expectedHash)
    #expect(client.ethSendTransactionCalls.count == 1)
    #expect(client.ethSendTransactionCalls[0].to == TestFixtures.recipientAddress)
    #expect(client.sendTransactionStatusCalls.count == 1)
  }

  @Test("sendToken with Turnkey returns mock tx hash and routes to contract address")
  func testSendERC20TokenTurnkey() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    stubSendTransactionRPCs()

    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    let expectedHash = "0x" + String(repeating: "e", count: 64)
    client.sendTransactionStatusQueue = [.broadcasted(hash: expectedHash)]

    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    let result = try await manager.sendToken(
      chainId: 1,
      contractAddress: TestFixtures.tokenAddress,
      to: TestFixtures.recipientAddress,
      amount: 100.0,
      decimals: 6
    )

    #expect(result.transactionHash == expectedHash)
    #expect(client.ethSendTransactionCalls.count == 1)
    // ERC-20 transfers target the token contract; recipient is encoded in calldata.
    #expect(client.ethSendTransactionCalls[0].to == TestFixtures.tokenAddress)
  }

  @Test("sendNative with Turnkey throws when ethSendTransaction fails")
  func testSendNativeTokenTurnkeyEthSendError() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    stubSendTransactionRPCs()

    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.ethSendTransactionError = NSError(
      domain: "Turnkey",
      code: 500,
      userInfo: [NSLocalizedDescriptionKey: "send failed"]
    )

    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.sendNative(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: 1.0
      )
    }
  }

  // MARK: - Polling status

  @Test("pollForTransactionHash throws when status reports failure")
  func testPollForTransactionHashFailureStatus() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    stubSendTransactionRPCs()

    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.sendTransactionStatusQueue = [.failed(message: "reverted")]

    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.sendNative(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: 1.0
      )
    }
  }

  @Test("pollForTransactionHash keeps polling until status returns a hash")
  func testPollForTransactionHashRetriesUntilSuccess() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    stubSendTransactionRPCs()

    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    let expectedHash = "0x" + String(repeating: "9", count: 64)
    client.sendTransactionStatusQueue = [
      .pending(),
      .broadcasted(hash: expectedHash)
    ]

    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    let result = try await manager.sendNative(
      chainId: 1,
      to: TestFixtures.recipientAddress,
      amount: 1.0
    )

    #expect(result.transactionHash == expectedHash)
    #expect(client.sendTransactionStatusCalls.count == 2)
  }

  // MARK: - withdrawCollateral with Turnkey (URLSession-stubbed)

  @Test("withdrawCollateral with Turnkey returns hash and signs typed data once")
  func testWithdrawCollateralTurnkey() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    stubSendTransactionRPCs()

    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    let expectedHash = "0x" + String(repeating: "7", count: 64)
    client.sendTransactionStatusQueue = [.broadcasted(hash: expectedHash)]

    let (manager, _, builder) = TestManagers.turnkeyManager(turnkey: mockTurnkey)
    builder.mockNonce = BigUInt(42)

    let txHash = try await manager.withdrawCollateral(
      chainId: 1,
      assetAddresses: TestFixtures.defaultWithdrawAddresses,
      amount: 100.0,
      decimals: 18,
      salt: TestFixtures.validSaltBase64,
      signature: TestFixtures.validSignatureHex,
      expiresAt: "1735689600",
      nonce: nil
    )

    #expect(txHash == expectedHash)
    #expect(mockTurnkey.signRawPayloadCalls.count == 1)
    #expect(client.ethSendTransactionCalls.count == 1)
    #expect(client.ethSendTransactionCalls[0].to == TestFixtures.contractAddress)
  }

  // MARK: - estimateWithdrawalFee with Turnkey

  @Test("estimateWithdrawalFee with Turnkey computes gas × price")
  func testEstimateWithdrawalFeeTurnkey() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    MockURLProtocol.stub(method: "eth_estimateGas", result: "0x5208") // 21000
    MockURLProtocol.stub(method: "eth_gasPrice", result: "0x4a817c800") // 20 gwei = 20_000_000_000

    let (manager, _, builder) = TestManagers.turnkeyManager()
    builder.mockNonce = BigUInt(1)

    let fee = try await manager.estimateWithdrawalFee(
      chainId: 1,
      addresses: TestFixtures.defaultWithdrawAddresses,
      amount: 100.0,
      decimals: 18,
      salt: TestFixtures.validSaltBase64,
      signature: TestFixtures.validSignatureHex,
      expiresAt: "1735689600"
    )

    let expectedFee = 20_000_000_000.0 / pow(10.0, 18.0) * 21_000.0
    #expect(fee == expectedFee)
  }

  @Test("estimateWithdrawalFee with Turnkey maps RPC network failures to networkError")
  func testEstimateWithdrawalFeeTurnkeyRpcNetworkError() async throws {
    MockURLProtocol.install()
    defer { MockURLProtocol.reset() }
    MockURLProtocol.stubError(
      method: "eth_estimateGas",
      error: NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
    )

    let (manager, _, builder) = TestManagers.turnkeyManager()
    builder.mockNonce = BigUInt(1)

    await #expect(throws: RainSDKError.networkError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600"
      )
    }
  }

  // MARK: - getTransactions error path

  @Test("getTransactions with Turnkey propagates getActivities error")
  func testGetTransactionsTurnkeyError() async throws {
    let mockTurnkey = MockTurnkey()
    let client = mockTurnkey.turnkeyClient as! MockTurnkeyClient
    client.getActivitiesError = NSError(
      domain: "Turnkey",
      code: 503,
      userInfo: [NSLocalizedDescriptionKey: "service unavailable"]
    )

    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.getTransactions(chainId: 1)
    }
  }

  // MARK: - Session resolution

  @Test("sendNative with Turnkey throws when session is missing")
  func testTurnkeyNoSession() async throws {
    let mockTurnkey = MockTurnkey(session: nil)
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    await #expect(throws: RainSDKError.tokenExpired) {
      _ = try await manager.sendNative(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: 1.0
      )
    }
  }

  @Test("sendNative with Turnkey throws when client is missing")
  func testTurnkeyNoClient() async throws {
    let mockTurnkey = MockTurnkey(client: nil)
    let (manager, _, _) = TestManagers.turnkeyManager(turnkey: mockTurnkey)

    await #expect(throws: RainSDKError.tokenExpired) {
      _ = try await manager.sendNative(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: 1.0
      )
    }
  }

  // MARK: - Helpers

  /// Stubs the three JSON-RPC calls made when building a Turnkey send-transaction body.
  private func stubSendTransactionRPCs() {
    MockURLProtocol.stub(method: "eth_getTransactionCount", result: "0x1")
    MockURLProtocol.stub(method: "eth_estimateGas", result: "0x5208")  // 21000
    MockURLProtocol.stub(method: "eth_gasPrice", result: "0x4a817c800") // 20 gwei
  }
}
