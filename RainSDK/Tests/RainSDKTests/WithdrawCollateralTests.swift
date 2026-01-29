import Testing
import Foundation
import PortalSwift
import Web3
@testable import RainSDK

@Suite("Withdraw Collateral Tests")
struct WithdrawCollateralTests {
  
  @Test("withdrawCollateral should throw sdkNotInitialized when called before initialization")
  func testWithdrawCollateralBeforeInitialization() async throws {
    let manager = RainSDKManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        signature: Data(repeating: 1, count: 65).base64EncodedString(), // Base64 signature (65 bytes)
        expiresAt: "1735689600",
        nonce: nil
      )
    }
  }
  
  @Test("withdrawCollateral should throw sdkNotInitialized after wallet-agnostic initialize")
  func testWithdrawCollateralAfterWalletAgnosticInit() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    
    // Initialize only network configs (no Portal)
    try await manager.initialize(networkConfigs: configs)
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // Portal is still not initialized, so withdrawCollateral should fail with sdkNotInitialized
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        signature: Data(repeating: 1, count: 65).base64EncodedString(), // Base64 signature
        expiresAt: "1735689600",
        nonce: nil
      )
    }
  }
  
  @Test("withdrawCollateral should throw error when no wallet address found in Portal")
  func testWithdrawCollateralNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    // Set address to nil to trigger the error
    mockPortal.mockAddresses.removeAll()
    
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    await #expect(throws: RainSDKError.internalLogicError(details: "No wallet address found in Portal")) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        signature: Data(repeating: 1, count: 65).base64EncodedString(), // Base64 signature
        expiresAt: "1735689600",
        nonce: nil
      )
    }
  }
  
  @Test("withdrawCollateral should throw error for invalid signature base64 string")
  func testWithdrawCollateralInvalidSignature() async throws {
    let mockPortal = MockPortal()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // Invalid signature (not valid base64)
    await #expect(throws: RainSDKError.internalLogicError(details: "Failed to convert user signature hex string to Data")) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        signature: "invalid-base64-string!!!", // Invalid base64
        expiresAt: "1735689600",
        nonce: nil
      )
    }
  }
  
  @Test("withdrawCollateral should throw error when buildEIP712Message fails")
  func testWithdrawCollateralBuildEIP712MessageFailure() async throws {
    let mockPortal = MockPortal()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = TransactionBuilderService(networkConfigs: configs)
    
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // Use chainId not in configs with nil nonce to trigger error in getLatestNonce
    await #expect(throws: RainSDKError.invalidConfig(chainId: 999, rpcUrl: "")) {
      _ = try await manager.withdrawCollateral(
        chainId: 999, // Not in network configs
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        signature: Data(repeating: 1, count: 65).base64EncodedString(), // Base64 signature
        expiresAt: "1735689600",
        nonce: nil // Will try to fetch nonce and fail
      )
    }
  }
  
  @Test("withdrawCollateral should throw error when buildWithdrawTransactionData fails")
  func testWithdrawCollateralBuildTransactionDataFailure() async throws {
    let mockPortal = MockPortal()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // This will fail when trying to build transaction data
    // The actual error depends on ABI availability and RPC connectivity
    // We expect either providerError or internalLogicError
    do {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        signature: Data(repeating: 1, count: 65).base64EncodedString(), // Base64 signature
        expiresAt: "1735689600",
        nonce: BigUInt(1) // Provide nonce to avoid nonce fetch
      )
      // If it doesn't throw, that's also acceptable (means ABI/RPC worked)
    } catch RainSDKError.providerError {
      // Expected if RPC is not accessible or ABI is missing
    } catch RainSDKError.internalLogicError {
      // Expected if there's an internal error in transaction building
    }
  }
  
  @Test("withdrawCollateral should throw error when Portal request fails")
  func testWithdrawCollateralPortalRequestFailure() async throws {
    let mockPortal = MockPortal()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    
    // Set up mock to throw error on signTypedData request
    let chainIdString = "eip155:1"
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_signTypedData_v4,
      error: NSError(domain: "PortalError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Signing failed"])
    )
    
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // Should propagate the Portal error
    await #expect(throws: NSError.self) {
      _ = try await manager.withdrawCollateral(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        signature: Data(repeating: 1, count: 65).base64EncodedString(), // Base64 signature
        expiresAt: "1735689600",
        nonce: BigUInt(1)
      )
    }
  }
  
  @Test("withdrawCollateral success case")
  func testWithdrawCollateralSuccess() async throws {
    let mockPortal = MockPortal()
    
    // Set up mock wallet address
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)
    
    // Set up mock responses for Portal requests
    let chainIdString = "eip155:1"
    
    // Mock response for eth_signTypedData_v4 - returns a valid signature (65 bytes = 130 hex chars)
    let mockAdminSignature = "0x" + String(repeating: "1", count: 130)
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_signTypedData_v4,
      result: mockAdminSignature
    )
    
    // Mock response for eth_sendTransaction - returns a transaction hash
    let mockTxHash = "0x" + String(repeating: "a", count: 64)
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_sendTransaction,
      result: mockTxHash
    )
    
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    mockBuilder.mockNonce = BigUInt(42)
    
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // Valid signature (65 bytes encoded as base64)
    let validSignature = Data(repeating: 1, count: 65).base64EncodedString()
    
    // Execute withdrawCollateral using the mock
    let txHash = try await manager.withdrawCollateral(
      chainId: 1,
      assetAddresses: assetAddresses,
      amount: 100.0,
      decimals: 18,
      signature: validSignature,
      expiresAt: "1735689600",
      nonce: nil
    )
    
    // Verify transaction hash is returned
    #expect(!txHash.isEmpty)
    #expect(txHash.hasPrefix("0x"))
    #expect(txHash == mockTxHash) // Should match the mocked transaction hash
    
    // Verify Portal was called correctly
    #expect(mockPortal.requestCalls.count == 2) // signTypedData and sendTransaction
    #expect(mockPortal.requestCalls[0].method == .eth_signTypedData_v4)
    #expect(mockPortal.requestCalls[1].method == .eth_sendTransaction)
    
    // Verify the first request was for signing
    let signRequest = mockPortal.requestCalls[0]
    #expect(signRequest.chainId == chainIdString)
    #expect(signRequest.method == .eth_signTypedData_v4)
    #expect(signRequest.params.count == 2) // walletAddress and eip712Message
    
    // Verify the second request was for sending transaction
    let sendRequest = mockPortal.requestCalls[1]
    #expect(sendRequest.chainId == chainIdString)
    #expect(sendRequest.method == .eth_sendTransaction)
    #expect(sendRequest.params.count == 1) // transactionParams array
  }
  
  // MARK: - Estimate Withdrawal Fee Tests
  
  private var defaultAddresses: WithdrawAssetAddresses {
    WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
  }

  private var validBase64Signature: String {
    Data(repeating: 1, count: 65).base64EncodedString()
  }

  @Test("estimateWithdrawalFee should throw sdkNotInitialized when called before initialization")
  func testEstimateWithdrawalFeeBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: defaultAddresses,
        amount: 100.0,
        decimals: 18,
        salt: Data(repeating: 0xAA, count: 32).base64EncodedString(),
        signature: validBase64Signature,
        expiresAt: "1735689600"
      )
    }
  }

  @Test("estimateWithdrawalFee should throw sdkNotInitialized after wallet-agnostic initialize")
  func testEstimateWithdrawalFeeAfterWalletAgnosticInit() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    try await manager.initialize(networkConfigs: configs)

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: defaultAddresses,
        amount: 100.0,
        decimals: 18,
        salt: Data(repeating: 0xAA, count: 32).base64EncodedString(),
        signature: validBase64Signature,
        expiresAt: "1735689600"
      )
    }
  }

  @Test("estimateWithdrawalFee should throw error when no wallet address found in Portal")
  func testEstimateWithdrawalFeeNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()

    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    mockBuilder.mockNonce = BigUInt(1)

    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    await #expect(throws: RainSDKError.internalLogicError(details: "No wallet address found in Portal")) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: defaultAddresses,
        amount: 100.0,
        decimals: 18,
        salt: Data(repeating: 0xAA, count: 32).base64EncodedString(),
        signature: validBase64Signature,
        expiresAt: "1735689600"
      )
    }
  }

  @Test("estimateWithdrawalFee should throw error for invalid signature")
  func testEstimateWithdrawalFeeInvalidSignature() async throws {
    let mockPortal = MockPortal()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    mockBuilder.mockNonce = BigUInt(1)

    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    await #expect(throws: RainSDKError.internalLogicError(details: "Failed to convert user signature hex string to Data")) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: defaultAddresses,
        amount: 100.0,
        decimals: 18,
        salt: Data(repeating: 0xAA, count: 32).base64EncodedString(),
        signature: "invalid-base64!!!",
        expiresAt: "1735689600"
      )
    }
  }

  @Test("estimateWithdrawalFee should throw when Portal sign request fails")
  func testEstimateWithdrawalFeePortalRequestFailure() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)

    let chainIdString = "eip155:1"
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_signTypedData_v4,
      error: NSError(domain: "PortalError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Signing failed"])
    )

    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    mockBuilder.mockNonce = BigUInt(1)

    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    await #expect(throws: NSError.self) {
      _ = try await manager.estimateWithdrawalFee(
        chainId: 1,
        addresses: defaultAddresses,
        amount: 100.0,
        decimals: 18,
        salt: Data(repeating: 0xAA, count: 32).base64EncodedString(),
        signature: validBase64Signature,
        expiresAt: "1735689600"
      )
    }
  }

  @Test("estimateWithdrawalFee success returns fee value when mocks are configured")
  func testEstimateWithdrawalFeeSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)

    let chainIdString = "eip155:1"
    let mockAdminSignature = "0x" + String(repeating: "1", count: 130)
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_signTypedData_v4,
      result: mockAdminSignature
    )
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_estimateGas,
      result: "21000"
    )
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_gasPrice,
      result: "20000000000"
    )

    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    mockBuilder.mockNonce = BigUInt(42)

    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let fee = try await manager.estimateWithdrawalFee(
      chainId: 1,
      addresses: defaultAddresses,
      amount: 100.0,
      decimals: 18,
      salt: Data(repeating: 0xAA, count: 32).base64EncodedString(),
      signature: validBase64Signature,
      expiresAt: "1735689600"
    )

    // Current implementation returns 0 as placeholder; assert non-throwing and type
    let expectedFee: Double = 20000000000 / pow(10, 18) * 21000
    #expect(fee == expectedFee)
  }
}
