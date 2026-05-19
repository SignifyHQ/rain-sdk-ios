import Testing
import Foundation
import Web3
import Web3Core
@testable import RainSDK

@Suite("Transaction Building Tests")
struct TransactionBuildingTests {

  // MARK: - buildEIP712Message success cases

  @Test("buildEIP712Message succeeds with valid inputs and provided nonce")
  func testBuildEIP712MessageWithNonce() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    let chainId = 1
    let nonce = BigUInt(42)
    let amount: Double = 100.0
    let decimals = 18

    let (message, _) = try await manager.buildEIP712Message(
      chainId: chainId,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: amount,
      decimals: decimals,
      nonce: nonce
    )

    let jsonObject = try parseJSON(message)
    #expect(jsonObject["primaryType"] as? String == "Withdraw")

    let domain = jsonObject["domain"] as? [String: Any]
    #expect(domain?["name"] as? String == "Collateral")
    #expect(domain?["version"] as? String == "2")
    #expect(domain?["chainId"] as? Int == chainId)
    #expect(domain?["verifyingContract"] as? String == TestFixtures.proxyAddress)
    #expect(domain?["salt"] != nil)

    let messageData = jsonObject["message"] as? [String: Any]
    #expect(messageData?["user"] as? String == TestFixtures.walletAddress)
    #expect(messageData?["asset"] as? String == TestFixtures.tokenAddress)
    #expect(messageData?["recipient"] as? String == TestFixtures.recipientAddress)
    #expect(messageData?["nonce"] as? String == nonce.description)

    let expectedAmount = BigUInt(amount * pow(10.0, Double(decimals)))
    #expect(messageData?["amount"] as? String == expectedAmount.description)
  }

  @Test("buildEIP712Message fetches nonce from contract when nil")
  func testBuildEIP712MessageWithNilNonce() async throws {
    let configs = TestFixtures.configs()
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    mockBuilder.mockNonce = BigUInt(42)
    let manager = RainSDKManager(transactionBuilder: mockBuilder)

    let (message, _) = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: 100.0,
      decimals: 18,
      nonce: nil
    )

    let messageData = try parseJSON(message)["message"] as? [String: Any]
    #expect(messageData?["nonce"] as? String == "42")
  }

  @Test("buildEIP712Message handles zero amount")
  func testBuildEIP712MessageZeroAmount() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    let (message, _) = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: 0.0,
      decimals: 18,
      nonce: BigUInt(0)
    )

    let messageData = try parseJSON(message)["message"] as? [String: Any]
    #expect(messageData?["amount"] as? String == "0")
  }

  @Test("buildEIP712Message handles 6-decimal tokens (USDC-like)")
  func testBuildEIP712MessageDifferentDecimals() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    let (message, _) = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: 100.5,
      decimals: 6,
      nonce: BigUInt(1)
    )

    let messageData = try parseJSON(message)["message"] as? [String: Any]
    #expect(messageData?["amount"] as? String == "100500000")
  }

  @Test("buildEIP712Message generates different salt on each call")
  func testBuildEIP712MessageDifferentSalt() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    let (message1, salt1) = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )
    let (message2, salt2) = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )

    #expect(message1 != message2)
    #expect(salt1 != salt2)
    #expect(salt1.hasPrefix("0x"))
  }

  @Test("buildEIP712Message handles very large amounts")
  func testBuildEIP712MessageLargeAmount() async throws {
    let manager = try await TestManagers.walletAgnosticManager()
    let amount: Double = 1_000_000_000.0
    let decimals = 18

    let (message, _) = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: amount,
      decimals: decimals,
      nonce: BigUInt(1)
    )

    let messageData = try parseJSON(message)["message"] as? [String: Any]
    let expectedAmount = BigUInt(amount * pow(10.0, Double(decimals)))
    #expect(messageData?["amount"] as? String == expectedAmount.description)
  }

  @Test("buildEIP712Message respects different chain IDs")
  func testBuildEIP712MessageDifferentChainIds() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")
    ]
    try await manager.initialize(networkConfigs: configs)

    let (message1, _) = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )
    let (message137, _) = try await manager.buildEIP712Message(
      chainId: 137,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )

    #expect((try parseJSON(message1)["domain"] as? [String: Any])?["chainId"] as? Int == 1)
    #expect((try parseJSON(message137)["domain"] as? [String: Any])?["chainId"] as? Int == 137)
  }

  // MARK: - buildEIP712Message failure cases

  @Test("buildEIP712Message throws sdkNotInitialized before initialization")
  func testBuildEIP712MessageBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      try await manager.buildEIP712Message(
        chainId: 1,
        walletAddress: TestFixtures.walletAddress,
        assetAddresses: TestFixtures.defaultEIP712Addresses,
        amount: 100.0,
        decimals: 18,
        nonce: BigUInt(1)
      )
    }
  }

  @Test("buildEIP712Message throws invalidConfig for unknown chainId when nonce is nil")
  func testBuildEIP712MessageInvalidChainId() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    await #expect(throws: RainSDKError.invalidConfig(chainId: 999, rpcUrl: "")) {
      try await manager.buildEIP712Message(
        chainId: 999,
        walletAddress: TestFixtures.walletAddress,
        assetAddresses: TestFixtures.defaultEIP712Addresses,
        amount: 100.0,
        decimals: 18,
        nonce: nil
      )
    }
  }

  @Test("buildEIP712Message succeeds with unknown chainId when nonce is provided")
  func testBuildEIP712MessageInvalidChainIdWithNonce() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    let (message, _) = try await manager.buildEIP712Message(
      chainId: 999,
      walletAddress: TestFixtures.walletAddress,
      assetAddresses: TestFixtures.defaultEIP712Addresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )

    let domain = try parseJSON(message)["domain"] as? [String: Any]
    #expect(domain?["chainId"] as? Int == 999)
  }

  // MARK: - buildWithdrawTransactionData

  @Test("buildWithdrawTransactionData returns mock calldata with valid inputs")
  func testBuildWithdrawTransactionDataSuccess() async throws {
    let configs = TestFixtures.configs()
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(transactionBuilder: mockBuilder)

    let txData = try await manager.buildWithdrawTransactionData(
      chainId: 1,
      assetAddresses: TestFixtures.defaultWithdrawAddresses,
      amount: 100.0,
      decimals: 18,
      expiresAt: "1735689600",
      salt: Data([UInt8](repeating: 0x11, count: 32)),
      signatureData: Data([UInt8](repeating: 0x42, count: 65)),
      adminSalt: Data([UInt8](repeating: 0xAA, count: 32)),
      adminSignature: Data([UInt8](repeating: 0xBB, count: 65))
    )

    #expect(txData.hasPrefix("0x"))
    // Mock builder always returns "0x" + "a1b2c3d4" × 16
    #expect(txData == "0x" + String(repeating: "a1b2c3d4", count: 16))
  }

  @Test("buildWithdrawTransactionData throws sdkNotInitialized before initialization")
  func testBuildWithdrawTransactionDataBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        salt: Data([UInt8](repeating: 0x11, count: 32)),
        signatureData: Data([UInt8](repeating: 0x42, count: 65)),
        adminSalt: Data([UInt8](repeating: 0xAA, count: 32)),
        adminSignature: Data([UInt8](repeating: 0xBB, count: 65))
      )
    }
  }

  @Test("buildWithdrawTransactionData throws for invalid contract address")
  func testBuildWithdrawTransactionDataInvalidContractAddress() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    let addresses = WithdrawAssetAddresses(
      contractAddress: "invalid-address",
      proxyAddress: TestFixtures.proxyAddress,
      recipientAddress: TestFixtures.recipientAddress,
      tokenAddress: TestFixtures.tokenAddress
    )

    await #expect(throws: RainSDKError.internalLogicError(details: "Error building transaction parameters for withdrawal. One of the addresses could not be built")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: addresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        salt: Data([UInt8](repeating: 0x11, count: 32)),
        signatureData: Data([UInt8](repeating: 0x42, count: 65)),
        adminSalt: Data([UInt8](repeating: 0xAA, count: 32)),
        adminSignature: Data([UInt8](repeating: 0xBB, count: 65))
      )
    }
  }

  @Test("buildWithdrawTransactionData throws for invalid proxy address")
  func testBuildWithdrawTransactionDataInvalidProxyAddress() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    let addresses = WithdrawAssetAddresses(
      contractAddress: TestFixtures.contractAddress,
      proxyAddress: "invalid-address",
      recipientAddress: TestFixtures.recipientAddress,
      tokenAddress: TestFixtures.tokenAddress
    )

    await #expect(throws: RainSDKError.internalLogicError(details: "Error building transaction parameters for withdrawal. One of the addresses could not be built")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: addresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        salt: Data([UInt8](repeating: 0x11, count: 32)),
        signatureData: Data([UInt8](repeating: 0x42, count: 65)),
        adminSalt: Data([UInt8](repeating: 0xAA, count: 32)),
        adminSignature: Data([UInt8](repeating: 0xBB, count: 65))
      )
    }
  }

  @Test("buildWithdrawTransactionData throws for invalid recipient address")
  func testBuildWithdrawTransactionDataInvalidRecipientAddress() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    let addresses = WithdrawAssetAddresses(
      contractAddress: TestFixtures.contractAddress,
      proxyAddress: TestFixtures.proxyAddress,
      recipientAddress: "invalid-address",
      tokenAddress: TestFixtures.tokenAddress
    )

    await #expect(throws: RainSDKError.internalLogicError(details: "Error building transaction parameters for withdrawal. One of the addresses could not be built")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: addresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        salt: Data([UInt8](repeating: 0x11, count: 32)),
        signatureData: Data([UInt8](repeating: 0x42, count: 65)),
        adminSalt: Data([UInt8](repeating: 0xAA, count: 32)),
        adminSignature: Data([UInt8](repeating: 0xBB, count: 65))
      )
    }
  }

  @Test("buildWithdrawTransactionData throws for invalid expiration timestamp")
  func testBuildWithdrawTransactionDataInvalidExpiration() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    await #expect(throws: RainSDKError.internalLogicError(details: "Invalid expiration timestamp format. Expected ISO8601 or Unix timestamp string")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: TestFixtures.defaultWithdrawAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "invalid-timestamp",
        salt: Data([UInt8](repeating: 0x11, count: 32)),
        signatureData: Data([UInt8](repeating: 0x42, count: 65)),
        adminSalt: Data([UInt8](repeating: 0xAA, count: 32)),
        adminSignature: Data([UInt8](repeating: 0xBB, count: 65))
      )
    }
  }

  @Test("buildWithdrawTransactionData accepts ISO8601 timestamp")
  func testBuildWithdrawTransactionDataISO8601Timestamp() async throws {
    let configs = TestFixtures.configs()
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(transactionBuilder: mockBuilder)

    let txData = try await manager.buildWithdrawTransactionData(
      chainId: 1,
      assetAddresses: TestFixtures.defaultWithdrawAddresses,
      amount: 100.0,
      decimals: 18,
      expiresAt: "2025-01-01T00:00:00Z",
      salt: Data([UInt8](repeating: 0x11, count: 32)),
      signatureData: Data([UInt8](repeating: 0x42, count: 65)),
      adminSalt: Data([UInt8](repeating: 0xAA, count: 32)),
      adminSignature: Data([UInt8](repeating: 0xBB, count: 65))
    )

    #expect(txData.hasPrefix("0x"))
  }

  // MARK: - Live network integration

  /// Integration test: hits Avalanche Fuji RPC to read the on-chain nonce.
  /// Verifies the call succeeds, the value fits uint256, and consecutive reads are stable
  /// (the contract is read-only from our side — no concurrent withdrawals during the test).
  /// Known tradeoff (accepted for now): this is intentionally a live-network dependency.
  /// Keep this comment until we split integration tests from default unit-test runs.
  /// Skip locally by filtering out this suite if offline.
  @Test("getLatestNonce reads a stable uint256 from a live Fuji contract")
  func testGetLatestNonceFromRealContract() async throws {
    let chainId = 43113
    let contractAddress = "0x5a022623280AA5E922A4D9BB3024fA7D70D7e789"
    let builder = TransactionBuilderService(
      networkConfigs: [NetworkConfig(chainId: chainId, rpcUrl: "https://avalanche-fuji-c-chain-rpc.publicnode.com")]
    )

    let first = try await builder.getLatestNonce(proxyAddress: contractAddress, chainId: chainId)
    let second = try await builder.getLatestNonce(proxyAddress: contractAddress, chainId: chainId)

    #expect(first == second, "Consecutive nonce reads on a stable contract must be equal")
    #expect(first.bitWidth <= 256, "Nonce must fit in uint256")
  }

  @Test("buildWithdrawTransactionData accepts 6-decimal tokens")
  func testBuildWithdrawTransactionDataDifferentDecimals() async throws {
    let configs = TestFixtures.configs()
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(transactionBuilder: mockBuilder)

    let txData = try await manager.buildWithdrawTransactionData(
      chainId: 1,
      assetAddresses: TestFixtures.defaultWithdrawAddresses,
      amount: 100.5,
      decimals: 6,
      expiresAt: "1735689600",
      salt: Data([UInt8](repeating: 0x11, count: 32)),
      signatureData: Data([UInt8](repeating: 0x42, count: 65)),
      adminSalt: Data([UInt8](repeating: 0xAA, count: 32)),
      adminSignature: Data([UInt8](repeating: 0xBB, count: 65))
    )

    #expect(txData.hasPrefix("0x"))
  }
}

// MARK: - Private helpers

private func parseJSON(_ string: String) throws -> [String: Any] {
  guard let data = string.data(using: .utf8) else {
    throw NSError(domain: "TestHelpers", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON string"])
  }
  guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    throw NSError(domain: "TestHelpers", code: -2, userInfo: [NSLocalizedDescriptionKey: "Expected JSON object"])
  }
  return dict
}
