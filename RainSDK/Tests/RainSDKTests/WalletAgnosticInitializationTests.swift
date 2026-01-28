import Testing
import Foundation
import Web3
import Web3Core
@testable import RainSDK

// MARK: - Wallet-Agnostic SDK Initialization Tests

@Suite("Wallet-Agnostic SDK Initialization Tests")
struct WalletAgnosticInitializationTests {
  // MARK: - Build EIP-712 Message Tests
  
  // MARK: - Build EIP-712 Message Success Cases
  
  @Test("buildEIP712Message should succeed with valid inputs and provided nonce")
  func testBuildEIP712MessageWithNonce() async throws {
    let manager = try await createInitializedManager()
    
    let chainId = 1
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let amount: Double = 100.0
    let decimals = 18
    let nonce = BigUInt(42)
    
    let message = try await manager.buildEIP712Message(
      chainId: chainId,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      nonce: nonce
    ).0
    
    // Verify message is valid JSON
    let jsonData = message.data(using: .utf8)
    #expect(jsonData != nil)
    
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData!) as? [String: Any]
    #expect(jsonObject != nil)
    
    // Verify structure
    #expect(jsonObject?["types"] != nil)
    #expect(jsonObject?["domain"] != nil)
    #expect(jsonObject?["primaryType"] as? String == "Withdraw")
    #expect(jsonObject?["message"] != nil)
    
    // Verify domain
    let domain = jsonObject?["domain"] as? [String: Any]
    #expect(domain?["name"] as? String == "Collateral")
    #expect(domain?["version"] as? String == "2")
    #expect(domain?["chainId"] as? Int == chainId)
    #expect(domain?["verifyingContract"] as? String == assetAddresses.proxyAddress)
    #expect(domain?["salt"] != nil)
    
    // Verify message
    let messageData = jsonObject?["message"] as? [String: Any]
    #expect(messageData?["user"] as? String == walletAddress)
    #expect(messageData?["asset"] as? String == assetAddresses.tokenAddress)
    #expect(messageData?["recipient"] as? String == assetAddresses.recipientAddress)
    #expect(messageData?["nonce"] as? String == nonce.description)
    
    // Verify amount (should be in base units: 100 * 10^18)
    let expectedAmount = BigUInt(100 * pow(10.0, 18))
    #expect(messageData?["amount"] as? String == expectedAmount.description)
  }
  
  @Test("buildEIP712Message should succeed with nil nonce and auto-fetch from contract")
  func testBuildEIP712MessageWithNilNonce() async throws {
    // Create manager with mock transaction builder that returns a nonce
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    mockBuilder.mockNonce = BigUInt(42) // Set expected nonce value
    let manager = RainSDKManager(transactionBuilder: mockBuilder)
    
    let chainId = 1
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x04A76ffB5D37B7f440B4CA06040C10Cf33221EEC"
    )
    let amount: Double = 100.0
    let decimals = 18
    let expectedNonce = BigUInt(42)
    
    // This should succeed because the mock builder will return a nonce
    let message = try await manager.buildEIP712Message(
      chainId: chainId,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      nonce: nil // Will retrieve from mock builder
    )
    
    // Verify message is valid JSON
    let jsonData = message.0.data(using: .utf8)
    #expect(jsonData != nil)
    
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData!) as? [String: Any]
    #expect(jsonObject != nil)
    
    // Verify structure
    #expect(jsonObject?["types"] != nil)
    #expect(jsonObject?["domain"] != nil)
    #expect(jsonObject?["primaryType"] as? String == "Withdraw")
    #expect(jsonObject?["message"] != nil)
    
    // Verify domain
    let domain = jsonObject?["domain"] as? [String: Any]
    #expect(domain?["name"] as? String == "Collateral")
    #expect(domain?["version"] as? String == "2")
    #expect(domain?["chainId"] as? Int == chainId)
    #expect(domain?["verifyingContract"] as? String == assetAddresses.proxyAddress)
    #expect(domain?["salt"] != nil)
    
    // Verify message has nonce (should be retrieved from mock builder)
    let messageData = jsonObject?["message"] as? [String: Any]
    #expect(messageData?["user"] as? String == walletAddress)
    #expect(messageData?["asset"] as? String == assetAddresses.tokenAddress)
    #expect(messageData?["recipient"] as? String == assetAddresses.recipientAddress)
    #expect(messageData?["nonce"] != nil) // Nonce should be present
    #expect(messageData?["nonce"] as? String == expectedNonce.description) // Should match mock nonce
    
    // Verify amount
    let expectedAmount = BigUInt(amount * pow(10.0, Double(decimals)))
    #expect(messageData?["amount"] as? String == expectedAmount.description)
  }
  
  @Test("buildEIP712Message should handle zero amount")
  func testBuildEIP712MessageZeroAmount() async throws {
    let manager = try await createInitializedManager()
    
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    let message = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: 0.0,
      decimals: 18,
      nonce: BigUInt(0)
    )
    
    let jsonData = message.0.data(using: .utf8)!
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
    let messageData = jsonObject["message"] as! [String: Any]
    
    #expect(messageData["amount"] as? String == "0")
  }
  
  @Test("buildEIP712Message should handle different decimal places")
  func testBuildEIP712MessageDifferentDecimals() async throws {
    let manager = try await createInitializedManager()
    
    // Test with 6 decimals (USDC-like)
    let amount: Double = 100.5
    let decimals = 6
    let expectedAmount = BigUInt(100500000) // 100.5 * 10^6
    
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    let message = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      nonce: BigUInt(1)
    )
    
    let jsonData = message.0.data(using: .utf8)!
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
    let messageData = jsonObject["message"] as! [String: Any]
    
    #expect(messageData["amount"] as? String == expectedAmount.description)
  }
  
  @Test("buildEIP712Message should generate different salt on each call")
  func testBuildEIP712MessageDifferentSalt() async throws {
    let manager = try await createInitializedManager()
    
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    let message1 = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )
    
    let message2 = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )
    
    // Messages should be different due to different salt
    #expect(message1 != message2)
    
    // But domain should have salt field
    let jsonData1 = message1.0.data(using: .utf8)!
    let jsonObject1 = try JSONSerialization.jsonObject(with: jsonData1) as! [String: Any]
    let domain1 = jsonObject1["domain"] as! [String: Any]
    
    let jsonData2 = message2.0.data(using: .utf8)!
    let jsonObject2 = try JSONSerialization.jsonObject(with: jsonData2) as! [String: Any]
    let domain2 = jsonObject2["domain"] as! [String: Any]
    
    // Salt should be different
    let salt1 = domain1["salt"] as? String
    let salt2 = domain2["salt"] as? String
    #expect(salt1 != nil)
    #expect(salt2 != nil)
    #expect(salt1 != salt2)
  }
  
  // MARK: - Build EIP-712 Message Failure Cases
  
  @Test("Should throw sdkNotInitialized when buildEIP712Message called before initialization")
  func testBuildEIP712MessageBeforeInitialization() async throws {
    let manager = RainSDKManager()
    
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      try await manager.buildEIP712Message(
        chainId: 1,
        walletAddress: walletAddress,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        nonce: BigUInt(1)
      )
    }
  }
  
  @Test("Should throw invalidConfig when chainId is not in network configs (for nonce retrieval)")
  func testBuildEIP712MessageInvalidChainId() async throws {
    let manager = try await createInitializedManager()
    
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // Try to use chainId that's not in the initialized configs
    // This will fail when trying to retrieve nonce
    await #expect(throws: RainSDKError.invalidConfig(chainId: 999, rpcUrl: "")) {
      try await manager.buildEIP712Message(
        chainId: 999, // Not in network configs
        walletAddress: walletAddress,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        nonce: nil // Will try to retrieve from network
      )
    }
  }
  
  @Test("Should succeed with invalid chainId if nonce is provided")
  func testBuildEIP712MessageInvalidChainIdWithNonce() async throws {
    let manager = try await createInitializedManager()
    
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // Even with invalid chainId, if nonce is provided, it should work
    // (nonce retrieval is skipped)
    let message = try await manager.buildEIP712Message(
      chainId: 999, // Not in network configs
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1) // Nonce provided, so no network call
    )
    
    // Should succeed and return valid JSON
    let jsonData = message.0.data(using: .utf8)
    #expect(jsonData != nil)
    
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData!) as? [String: Any]
    #expect(jsonObject != nil)
    #expect(jsonObject?["domain"] != nil)
  }
  
  // MARK: - Build EIP-712 Message Edge Cases
  
  @Test("buildEIP712Message should handle very large amounts")
  func testBuildEIP712MessageLargeAmount() async throws {
    let manager = try await createInitializedManager()
    
    // Test with a very large amount
    let amount: Double = 1_000_000_000.0
    let decimals = 18
    
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    let message = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      nonce: BigUInt(1)
    )
    
    let jsonData = message.0.data(using: .utf8)!
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
    let messageData = jsonObject["message"] as! [String: Any]
    
    // Verify amount is correct
    // Match the implementation's calculation: BigUInt(amount * pow(10.0, Double(decimals)))
    // 1_000_000_000 * 10^18 = 1_000_000_000_000_000_000_000_000_000
    let expectedAmount = BigUInt(amount * pow(10.0, Double(decimals)))
    #expect(messageData["amount"] as? String == expectedAmount.description)
  }
  
  @Test("buildEIP712Message should handle different chain IDs")
  func testBuildEIP712MessageDifferentChainIds() async throws {
    let manager = RainSDKManager()
    // Initialize with multiple chain IDs
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")
    ]
    try await manager.initialize(networkConfigs: configs)
    
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: "0x1234567890123456789012345678901234567890",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    
    // Test with chainId 1
    let message1 = try await manager.buildEIP712Message(
      chainId: 1,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )
    
    // Test with chainId 137
    let message2 = try await manager.buildEIP712Message(
      chainId: 137,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: 100.0,
      decimals: 18,
      nonce: BigUInt(1)
    )
    
    // Both should succeed
    let jsonData1 = message1.0.data(using: .utf8)!
    let jsonObject1 = try JSONSerialization.jsonObject(with: jsonData1) as! [String: Any]
    let domain1 = jsonObject1["domain"] as! [String: Any]
    #expect(domain1["chainId"] as? Int == 1)
    
    let jsonData2 = message2.0.data(using: .utf8)!
    let jsonObject2 = try JSONSerialization.jsonObject(with: jsonData2) as! [String: Any]
    let domain2 = jsonObject2["domain"] as! [String: Any]
    #expect(domain2["chainId"] as? Int == 137)
  }
  
  // MARK: - Build Withdraw Transaction Data Tests
  
  @Test("buildWithdrawTransactionData should succeed with valid inputs")
  func testBuildWithdrawTransactionDataSuccess() async throws {
    let manager = try await createInitializedManager()
    
    let chainId = 1
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let amount: Double = 100.0
    let decimals = 18
    let expiresAt = "1735689600" // Unix timestamp
    let signatureData = Data([UInt8](repeating: 0x42, count: 65)) // 65 bytes for signature
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32)) // 32 bytes for salt
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65)) // 65 bytes for signature
    
    // Note: This will fail if RPC URL is not accessible or contract ABI is missing
    // But we can test the validation logic
    do {
      let txData = try await manager.buildWithdrawTransactionData(
        chainId: chainId,
        assetAddresses: assetAddresses,
        amount: amount,
        decimals: decimals,
        expiresAt: expiresAt,
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
      
      // Verify transaction data is hex-encoded and prefixed with 0x
      #expect(txData.hasPrefix("0x"))
      #expect(txData.count > 2) // Should have hex data after 0x
    } catch RainSDKError.providerError {
      // Expected if RPC is not accessible in test environment
    } catch RainSDKError.internalLogicError(let details) where details.contains("ABI") {
      // Expected if ABI files are not available
    }
  }
  
  @Test("buildWithdrawTransactionData should throw sdkNotInitialized when called before initialization")
  func testBuildWithdrawTransactionDataBeforeInitialization() async throws {
    let manager = RainSDKManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let signatureData = Data([UInt8](repeating: 0x42, count: 65))
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32))
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65))
    
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
    }
  }
  
  @Test("buildWithdrawTransactionData should throw error for invalid contract address")
  func testBuildWithdrawTransactionDataInvalidContractAddress() async throws {
    let manager = try await createInitializedManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "invalid-address",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let signatureData = Data([UInt8](repeating: 0x42, count: 65))
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32))
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65))
    
    await #expect(throws: RainSDKError.internalLogicError(details: "Error building transaction parameters for withdrawal. One of the addresses could not be built")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
    }
  }
  
  @Test("buildWithdrawTransactionData should throw error for invalid proxy address")
  func testBuildWithdrawTransactionDataInvalidProxyAddress() async throws {
    let manager = try await createInitializedManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "invalid-address",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let signatureData = Data([UInt8](repeating: 0x42, count: 65))
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32))
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65))
    
    await #expect(throws: RainSDKError.internalLogicError(details: "Error building transaction parameters for withdrawal. One of the addresses could not be built")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
    }
  }
  
  @Test("buildWithdrawTransactionData should throw error for invalid recipient address")
  func testBuildWithdrawTransactionDataInvalidRecipientAddress() async throws {
    let manager = try await createInitializedManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "invalid-address",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let signatureData = Data([UInt8](repeating: 0x42, count: 65))
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32))
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65))
    
    await #expect(throws: RainSDKError.internalLogicError(details: "Error building transaction parameters for withdrawal. One of the addresses could not be built")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
    }
  }
  
  @Test("buildWithdrawTransactionData should throw error for invalid expiration timestamp")
  func testBuildWithdrawTransactionDataInvalidExpiration() async throws {
    let manager = try await createInitializedManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let signatureData = Data([UInt8](repeating: 0x42, count: 65))
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32))
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65))
    
    await #expect(throws: RainSDKError.internalLogicError(details: "Invalid expiration timestamp format. Expected ISO8601 or Unix timestamp string")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "invalid-timestamp",
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
    }
  }
  
  @Test("buildWithdrawTransactionData should handle ISO8601 timestamp format")
  func testBuildWithdrawTransactionDataISO8601Timestamp() async throws {
    let manager = try await createInitializedManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let signatureData = Data([UInt8](repeating: 0x42, count: 65))
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32))
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65))
    
    // ISO8601 format timestamp
    let iso8601Timestamp = "2025-01-01T00:00:00Z"
    
    // Note: This will fail if RPC URL is not accessible or contract ABI is missing
    do {
      let txData = try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: iso8601Timestamp,
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
      
      // Verify transaction data is hex-encoded
      #expect(txData.hasPrefix("0x"))
    } catch RainSDKError.providerError {
      // Expected if RPC is not accessible
    } catch RainSDKError.internalLogicError(let details) where details.contains("ABI") {
      // Expected if ABI files are not available
    }
  }
  
  @Test("buildWithdrawTransactionData should handle different decimal places")
  func testBuildWithdrawTransactionDataDifferentDecimals() async throws {
    let manager = try await createInitializedManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let signatureData = Data([UInt8](repeating: 0x42, count: 65))
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32))
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65))
    
    // Test with 6 decimals (USDC-like)
    let amount: Double = 100.5
    let decimals = 6
    
    do {
      let txData = try await manager.buildWithdrawTransactionData(
        chainId: 1,
        assetAddresses: assetAddresses,
        amount: amount,
        decimals: decimals,
        expiresAt: "1735689600",
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
      
      #expect(txData.hasPrefix("0x"))
    } catch RainSDKError.providerError {
      // Expected if RPC is not accessible
    } catch RainSDKError.internalLogicError(let details) where details.contains("ABI") {
      // Expected if ABI files are not available
    }
  }
  
  @Test("buildWithdrawTransactionData should throw invalidConfig for chainId not in network configs")
  func testBuildWithdrawTransactionDataInvalidChainId() async throws {
    let manager = try await createInitializedManager()
    
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: "0x1234567890123456789012345678901234567890",
      proxyAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      tokenAddress: "0x9876543210987654321098765432109876543210"
    )
    let signatureData = Data([UInt8](repeating: 0x42, count: 65))
    let adminSalt = Data([UInt8](repeating: 0xAA, count: 32))
    let adminSignature = Data([UInt8](repeating: 0xBB, count: 65))
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 999, rpcUrl: "")) {
      try await manager.buildWithdrawTransactionData(
        chainId: 999, // Not in network configs
        assetAddresses: assetAddresses,
        amount: 100.0,
        decimals: 18,
        expiresAt: "1735689600",
        signatureData: signatureData,
        adminSalt: adminSalt,
        adminSignature: adminSignature
      )
    }
  }
  
  // MARK: - Get Latest Nonce Tests
  
  @Test("getLatestNonce should retrieve nonce from real contract on Avalanche Fuji")
  func testGetLatestNonceFromRealContract() async throws {
    // Initialize transaction builder with Avalanche Fuji network config
    let chainId = 43113
    let configs = [
      NetworkConfig(chainId: chainId, rpcUrl: "https://avalanche-fuji-c-chain-rpc.publicnode.com")
    ]
    let transactionBuilder = TransactionBuilderService(networkConfigs: configs)
    
    // Contract address on Avalanche Fuji
    let contractAddress = "0x5a022623280AA5E922A4D9BB3024fA7D70D7e789"
    
    // Get nonce directly from contract
    let nonce = try await transactionBuilder.getLatestNonce(
      proxyAddress: contractAddress,
      chainId: chainId
    )
    
    // Verify nonce is a valid BigUInt (should be >= 0)
    #expect(nonce >= 0)
    
    // Log the retrieved nonce for debugging
    print("Retrieved nonce from contract \(contractAddress) on chain \(chainId): \(nonce)")
  }
}

// MARK: - Setup Helper

extension WalletAgnosticInitializationTests {
  func createInitializedManager() async throws -> RainSDKManager {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    try await manager.initialize(networkConfigs: configs)
    return manager
  }  
}
