import Testing
import Foundation
import Web3
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
    let collateralProxyAddress = "0x1234567890123456789012345678901234567890"
    let walletAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
    let tokenAddress = "0x9876543210987654321098765432109876543210"
    let amount: Double = 100.0
    let decimals = 18
    let recipientAddress = "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc"
    let nonce = BigUInt(42)
    
    let message = try await manager.buildEIP712Message(
      chainId: chainId,
      collateralProxyAddress: collateralProxyAddress,
      walletAddress: walletAddress,
      tokenAddress: tokenAddress,
      amount: amount,
      decimals: decimals,
      recipientAddress: recipientAddress,
      nonce: nonce
    )
    
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
    #expect(domain?["verifyingContract"] as? String == collateralProxyAddress)
    #expect(domain?["salt"] != nil)
    
    // Verify message
    let messageData = jsonObject?["message"] as? [String: Any]
    #expect(messageData?["user"] as? String == walletAddress)
    #expect(messageData?["asset"] as? String == tokenAddress)
    #expect(messageData?["recipient"] as? String == recipientAddress)
    #expect(messageData?["nonce"] as? String == nonce.description)
    
    // Verify amount (should be in base units: 100 * 10^18)
    let expectedAmount = BigUInt(100 * pow(10.0, 18))
    #expect(messageData?["amount"] as? String == expectedAmount.description)
  }
  
  @Test("buildEIP712Message should handle zero amount")
  func testBuildEIP712MessageZeroAmount() async throws {
    let manager = try await createInitializedManager()
    
    let message = try await manager.buildEIP712Message(
      chainId: 1,
      collateralProxyAddress: "0x1234567890123456789012345678901234567890",
      walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      tokenAddress: "0x9876543210987654321098765432109876543210",
      amount: 0.0,
      decimals: 18,
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      nonce: BigUInt(0)
    )
    
    let jsonData = message.data(using: .utf8)!
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
    
    let message = try await manager.buildEIP712Message(
      chainId: 1,
      collateralProxyAddress: "0x1234567890123456789012345678901234567890",
      walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      tokenAddress: "0x9876543210987654321098765432109876543210",
      amount: amount,
      decimals: decimals,
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      nonce: BigUInt(1)
    )
    
    let jsonData = message.data(using: .utf8)!
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
    let messageData = jsonObject["message"] as! [String: Any]
    
    #expect(messageData["amount"] as? String == expectedAmount.description)
  }
  
  @Test("buildEIP712Message should generate different salt on each call")
  func testBuildEIP712MessageDifferentSalt() async throws {
    let manager = try await createInitializedManager()
    
    let params = (
      chainId: 1,
      collateralProxyAddress: "0x1234567890123456789012345678901234567890",
      walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      tokenAddress: "0x9876543210987654321098765432109876543210",
      amount: 100.0,
      decimals: 18,
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      nonce: BigUInt(1)
    )
    
    let message1 = try await manager.buildEIP712Message(
      chainId: params.chainId,
      collateralProxyAddress: params.collateralProxyAddress,
      walletAddress: params.walletAddress,
      tokenAddress: params.tokenAddress,
      amount: params.amount,
      decimals: params.decimals,
      recipientAddress: params.recipientAddress,
      nonce: params.nonce
    )
    
    let message2 = try await manager.buildEIP712Message(
      chainId: params.chainId,
      collateralProxyAddress: params.collateralProxyAddress,
      walletAddress: params.walletAddress,
      tokenAddress: params.tokenAddress,
      amount: params.amount,
      decimals: params.decimals,
      recipientAddress: params.recipientAddress,
      nonce: params.nonce
    )
    
    // Messages should be different due to different salt
    #expect(message1 != message2)
    
    // But domain should have salt field
    let jsonData1 = message1.data(using: .utf8)!
    let jsonObject1 = try JSONSerialization.jsonObject(with: jsonData1) as! [String: Any]
    let domain1 = jsonObject1["domain"] as! [String: Any]
    
    let jsonData2 = message2.data(using: .utf8)!
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
    
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      try await manager.buildEIP712Message(
        chainId: 1,
        collateralProxyAddress: "0x1234567890123456789012345678901234567890",
        walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
        tokenAddress: "0x9876543210987654321098765432109876543210",
        amount: 100.0,
        decimals: 18,
        recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
        nonce: BigUInt(1)
      )
    }
  }
  
  @Test("Should throw invalidConfig when chainId is not in network configs (for nonce retrieval)")
  func testBuildEIP712MessageInvalidChainId() async throws {
    let manager = try await createInitializedManager()
    
    // Try to use chainId that's not in the initialized configs
    // This will fail when trying to retrieve nonce
    await #expect(throws: RainSDKError.invalidConfig(chainId: 999, rpcUrl: "")) {
      try await manager.buildEIP712Message(
        chainId: 999, // Not in network configs
        collateralProxyAddress: "0x1234567890123456789012345678901234567890",
        walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
        tokenAddress: "0x9876543210987654321098765432109876543210",
        amount: 100.0,
        decimals: 18,
        recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
        nonce: nil // Will try to retrieve from network
      )
    }
  }
  
  @Test("Should succeed with invalid chainId if nonce is provided")
  func testBuildEIP712MessageInvalidChainIdWithNonce() async throws {
    let manager = try await createInitializedManager()
    
    // Even with invalid chainId, if nonce is provided, it should work
    // (nonce retrieval is skipped)
    let message = try await manager.buildEIP712Message(
      chainId: 999, // Not in network configs
      collateralProxyAddress: "0x1234567890123456789012345678901234567890",
      walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      tokenAddress: "0x9876543210987654321098765432109876543210",
      amount: 100.0,
      decimals: 18,
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      nonce: BigUInt(1) // Nonce provided, so no network call
    )
    
    // Should succeed and return valid JSON
    let jsonData = message.data(using: .utf8)
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
    
    let message = try await manager.buildEIP712Message(
      chainId: 1,
      collateralProxyAddress: "0x1234567890123456789012345678901234567890",
      walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      tokenAddress: "0x9876543210987654321098765432109876543210",
      amount: amount,
      decimals: decimals,
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      nonce: BigUInt(1)
    )
    
    let jsonData = message.data(using: .utf8)!
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
    
    // Test with chainId 1
    let message1 = try await manager.buildEIP712Message(
      chainId: 1,
      collateralProxyAddress: "0x1234567890123456789012345678901234567890",
      walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      tokenAddress: "0x9876543210987654321098765432109876543210",
      amount: 100.0,
      decimals: 18,
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc",
      nonce: BigUInt(1)
    )
    
    // Test with chainId 137
    let message2 = try await manager.buildEIP712Message(
      chainId: 137,
      collateralProxyAddress: "0x1234567890123456789012345678901234567890",
      walletAddress: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
      tokenAddress: "0x9876543210987654321098765432109876543210",
      amount: 100.0,
      decimals: 18,
      recipientAddress: "0xfedcbafedcbafedcbafedcbafedcbafedc",
      nonce: BigUInt(1)
    )
    
    // Both should succeed
    let jsonData1 = message1.data(using: .utf8)!
    let jsonObject1 = try JSONSerialization.jsonObject(with: jsonData1) as! [String: Any]
    let domain1 = jsonObject1["domain"] as! [String: Any]
    #expect(domain1["chainId"] as? Int == 1)
    
    let jsonData2 = message2.data(using: .utf8)!
    let jsonObject2 = try JSONSerialization.jsonObject(with: jsonData2) as! [String: Any]
    let domain2 = jsonObject2["domain"] as! [String: Any]
    #expect(domain2["chainId"] as? Int == 137)
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
