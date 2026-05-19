import Testing
import Foundation
import Web3
@testable import PortalSwift
@testable import RainSDK

@Suite("Portal Adapter Tests")
struct PortalAdapterTests {

  // MARK: - Address / wallet info

  @Test("getWalletAddress returns address from Portal context")
  func testGetWalletAddressFromPortal() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let address = try await manager.getWalletAddress()
    #expect(address == TestFixtures.walletAddress)
  }

  // MARK: - getNativeBalance

  @Test("getNativeBalance returns 1.0 ETH and calls eth_getBalance on the correct chain")
  func testGetNativeBalanceSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let (manager, portal, _) = TestManagers.portalManager(portal: mockPortal)

    let balance = try await manager.getNativeBalance(chainId: 1)

    #expect(balance == 1.0)
    #expect(portal.requestCalls.count == 1)
    #expect(portal.requestCalls[0].method == .eth_getBalance)
    #expect(portal.requestCalls[0].chainId == "eip155:1")
  }

  @Test("getNativeBalance maps Portal request failures to providerError")
  func testGetNativeBalancePortalError() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_getBalance,
      error: NSError(domain: "RPC", code: -1, userInfo: [NSLocalizedDescriptionKey: "RPC error"])
    )
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  // MARK: - getERC20Balance (via RPC eth_call)

  @Test("getERC20Balance returns 0 when eth_call returns empty result")
  func testGetERC20BalanceReturnsZeroWhenCallReturnsEmpty() async throws {
    let (manager, _, _) = TestManagers.portalManager()
    let balance = try await manager.getERC20Balance(
      chainId: 1,
      tokenAddress: TestFixtures.usdcAddress
    )
    #expect(balance == 0.0)
  }

  @Test("getERC20Balance returns 1.0 with default 18 decimals")
  func testGetERC20BalanceSuccessDefaultDecimals() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    // 1 token with 18 decimals = 0x0de0b6b3a7640000 (1_000_000_000_000_000_000)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      result: PortalProviderRpcResponse(jsonrpc: "2.0", result: "0x0de0b6b3a7640000")
    )
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let balance = try await manager.getERC20Balance(chainId: 1, tokenAddress: TestFixtures.usdcAddress)

    #expect(balance == 1.0)
    #expect(mockPortal.requestCalls.count == 1)
    #expect(mockPortal.requestCalls[0].method == .eth_call)
    #expect(mockPortal.requestCalls[0].chainId == "eip155:1")
  }

  @Test("getERC20Balance returns 1.0 USDC with 6 decimals")
  func testGetERC20BalanceSuccessCustomDecimals() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    // 1 USDC with 6 decimals = 0x0F4240 (1_000_000)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      result: PortalProviderRpcResponse(jsonrpc: "2.0", result: "0x0F4240")
    )
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let balance = try await manager.getERC20Balance(
      chainId: 1,
      tokenAddress: TestFixtures.usdcAddress,
      decimals: 6
    )

    #expect(balance == 1.0)
  }

  @Test("getERC20Balance with nil decimals defaults to 18")
  func testGetERC20BalanceNilDecimalsDefaultsTo18() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    // 2.5 tokens with 18 decimals = 0x22B1C8C1227A0000
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      result: PortalProviderRpcResponse(jsonrpc: "2.0", result: "0x22B1C8C1227A0000")
    )
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let balance = try await manager.getERC20Balance(
      chainId: 1,
      tokenAddress: TestFixtures.usdcAddress,
      decimals: nil
    )

    #expect(balance == 2.5)
  }

  @Test("getERC20Balance throws providerError when portal request fails")
  func testGetERC20BalancePortalError() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      error: NSError(domain: "RPC", code: -1, userInfo: [NSLocalizedDescriptionKey: "RPC error"])
    )
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.getERC20Balance(chainId: 1, tokenAddress: TestFixtures.usdcAddress)
    }
  }

  // MARK: - getERC20Balances / getBalances

  @Test("getERC20Balances returns empty dictionary when Portal returns no tokens")
  func testGetERC20BalancesSuccessEmpty() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.mockAssetsResponse = AssetsResponse(nativeBalance: nil, tokenBalances: nil, nfts: nil)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let balances = try await manager.getERC20Balances(chainId: 1)
    #expect(balances.isEmpty)
  }

  @Test("getBalances returns native under empty key")
  func testGetBalancesSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.mockAssetsResponse = AssetsResponse(nativeBalance: nil, tokenBalances: nil, nfts: nil)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let balances = try await manager.getBalances(chainId: 1)
    #expect(balances[""] == 1.0)
  }

  // MARK: - sendNativeToken / sendERC20Token

  @Test("sendNativeToken with Portal returns mock tx hash and calls eth_call then eth_sendTransaction")
  func testSendNativeTokenSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)

    let mockTxHash = "0x" + String(repeating: "b", count: 64)
    mockPortal.setMockResponse(chainId: "eip155:1", method: .eth_sendTransaction, result: mockTxHash)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let txHash = try await manager.sendNativeToken(
      chainId: 1,
      to: TestFixtures.recipientAddress,
      amount: 1.5
    )

    #expect(txHash == mockTxHash)
    #expect(mockPortal.requestCalls.count == 2)
    #expect(mockPortal.requestCalls[0].method == .eth_call) // preflight simulation
    #expect(mockPortal.requestCalls[1].method == .eth_sendTransaction)
  }

  @Test("sendERC20Token with Portal returns mock tx hash and routes calldata via eth_sendTransaction")
  func testSendERC20TokenSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)

    let mockTxHash = "0x" + String(repeating: "c", count: 64)
    mockPortal.setMockResponse(chainId: "eip155:1", method: .eth_sendTransaction, result: mockTxHash)
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let txHash = try await manager.sendERC20Token(
      chainId: 1,
      contractAddress: TestFixtures.tokenAddress,
      to: TestFixtures.recipientAddress,
      amount: 100.0,
      decimals: 6
    )

    #expect(txHash == mockTxHash)
    #expect(mockPortal.requestCalls.count == 2)
    #expect(mockPortal.requestCalls[0].method == .eth_call)
    #expect(mockPortal.requestCalls[1].method == .eth_sendTransaction)
  }

  @Test("sendNativeToken with Portal maps send failures to providerError")
  func testSendNativeTokenPortalSendFailure() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_sendTransaction,
      error: NSError(domain: "PortalError", code: 500, userInfo: [NSLocalizedDescriptionKey: "send failed"])
    )
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.sendNativeToken(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: 1.0
      )
    }
  }

  @Test("sendERC20Token with Portal maps send failures to providerError")
  func testSendERC20TokenPortalSendFailure() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_sendTransaction,
      error: NSError(domain: "PortalError", code: 500, userInfo: [NSLocalizedDescriptionKey: "send failed"])
    )
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.sendERC20Token(
        chainId: 1,
        contractAddress: TestFixtures.tokenAddress,
        to: TestFixtures.recipientAddress,
        amount: 100.0,
        decimals: 6
      )
    }
  }

  // MARK: - withdrawCollateral / estimateWithdrawalFee

  @Test("withdrawCollateral with Portal signs typed data, simulates, then sends")
  func testWithdrawCollateralSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)

    let chainIdString = "eip155:1"
    let mockAdminSignature = "0x" + String(repeating: "1", count: 130)
    let mockTxHash = "0x" + String(repeating: "a", count: 64)
    mockPortal.setMockResponse(chainId: chainIdString, method: .eth_signTypedData_v4, result: mockAdminSignature)
    mockPortal.setMockResponse(chainId: chainIdString, method: .eth_sendTransaction, result: mockTxHash)

    let (manager, _, builder) = TestManagers.portalManager(portal: mockPortal)
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

    #expect(txHash == mockTxHash)
    #expect(mockPortal.requestCalls.count == 3)
    #expect(mockPortal.requestCalls[0].method == .eth_signTypedData_v4)
    #expect(mockPortal.requestCalls[1].method == .eth_call)
    #expect(mockPortal.requestCalls[2].method == .eth_sendTransaction)

    #expect(mockPortal.requestCalls[0].chainId == chainIdString)
    #expect(mockPortal.requestCalls[0].params.count == 2)
    #expect(mockPortal.requestCalls[2].params.count == 1)
  }

  @Test("estimateWithdrawalFee with Portal returns gasPrice × gasLimit fee")
  func testEstimateWithdrawalFeeSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)

    let chainIdString = "eip155:1"
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_signTypedData_v4,
      result: "0x" + String(repeating: "1", count: 130)
    )
    mockPortal.setMockResponse(chainId: chainIdString, method: .eth_estimateGas, result: "21000")
    mockPortal.setMockResponse(chainId: chainIdString, method: .eth_gasPrice, result: "20000000000")

    let (manager, _, builder) = TestManagers.portalManager(portal: mockPortal)
    builder.mockNonce = BigUInt(42)

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

  @Test("withdrawCollateral with Portal propagates sign error")
  func testWithdrawCollateralPortalRequestFailure() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_signTypedData_v4,
      error: NSError(domain: "PortalError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Signing failed"])
    )
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        salt: TestFixtures.validSaltBase64,
        signature: TestFixtures.validSignatureHex,
        expiresAt: "1735689600",
        nonce: BigUInt(1)
      )
    }
  }

  @Test("estimateWithdrawalFee with Portal maps sign failures to providerError")
  func testEstimateWithdrawalFeePortalRequestFailure() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_signTypedData_v4,
      error: NSError(domain: "PortalError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Signing failed"])
    )
    let (manager, _, builder) = TestManagers.portalManager(portal: mockPortal)
    builder.mockNonce = BigUInt(1)

    await #expect(throws: RainSDKError.providerError(underlying: NSError(domain: "x", code: 0))) {
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

  // MARK: - getTransactions

  @Test("getTransactions with Portal returns mapped WalletTransaction")
  func testGetTransactionsReturnsMappedList() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let fetchedTx = Self.makeFetchedTransaction(
      hash: "0xabc123",
      from: "0xfrom",
      to: "0xto",
      blockNum: "100",
      chainId: 1
    )
    mockPortal.mockFetchedTransactions = [fetchedTx]
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    let list = try await manager.getTransactions(chainId: 1)

    #expect(list.count == 1)
    #expect(list[0].hash == "0xabc123")
    #expect(list[0].from == "0xfrom")
    #expect(list[0].to == "0xto")
    #expect(list[0].blockNum == "100")
    #expect(list[0].chainId == 1)
  }

  @Test("getTransactions with Portal passes order parameter through")
  func testGetTransactionsWithOrder() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress(TestFixtures.walletAddress, forNamespace: PortalNamespace.eip155)
    let fetchedTx = Self.makeFetchedTransaction(hash: "0xdef", from: "0xa", to: "0xb", blockNum: "200", chainId: 137)
    mockPortal.mockFetchedTransactions = [fetchedTx]
    let configs = [NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")]
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal, configs: configs)

    let list = try await manager.getTransactions(chainId: 137, limit: 10, offset: 0, order: .DESC)
    #expect(list.count == 1)
    #expect(list[0].hash == "0xdef")
    #expect(list[0].chainId == 137)
  }

  // MARK: - Helpers

  private static func makeFetchedTransaction(
    hash: String,
    from: String,
    to: String,
    blockNum: String,
    chainId: Int
  ) -> FetchedTransaction {
    let json = """
    {
      "blockNum": "\(blockNum)",
      "uniqueId": "uid-\(hash)",
      "hash": "\(hash)",
      "from": "\(from)",
      "to": "\(to)",
      "value": 1.0,
      "category": "external",
      "metadata": { "blockTimestamp": "2024-01-01T00:00:00Z" },
      "chainId": \(chainId)
    }
    """
    return try! JSONDecoder().decode(FetchedTransaction.self, from: Data(json.utf8))
  }
}
