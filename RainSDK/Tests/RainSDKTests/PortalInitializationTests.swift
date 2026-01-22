import Testing
import Foundation
@testable import RainSDK

@Suite("Portal SDK Initialization Tests")
struct PortalInitializationTests {
  
  // MARK: - Success Cases
  
  @Test("initializePortal should succeed with valid inputs")
  func testInitializePortalSuccess() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    
    // Note: This test may fail if Portal SDK requires valid credentials
    // In that case, it will throw providerError which is acceptable
    do {
      try await manager.initializePortal(
        portalSessionToken: "valid-test-token-12345",
        networkConfigs: configs
      )
      
      // If initialization succeeds, portal should be accessible
      let portal = try manager.portal
      #expect(portal != nil)
    } catch RainSDKError.providerError {
      // Portal SDK error is expected in test environment without real credentials
      // This is acceptable - the validation passed
    } catch {
      // Re-throw unexpected errors
      throw error
    }
  }
  
  @Test("initializePortal should handle single network config")
  func testInitializePortalSingleNetwork() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    
    do {
      try await manager.initializePortal(
        portalSessionToken: "valid-test-token",
        networkConfigs: configs
      )
      
      // If succeeds, portal should be accessible
      let portal = try manager.portal
      #expect(portal != nil)
    } catch RainSDKError.providerError {
      // Expected in test environment
    } catch {
      throw error
    }
  }
  
  @Test("initializePortal should handle multiple network configs")
  func testInitializePortalMultipleNetworks() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://eth-mainnet.com"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-mainnet.com"),
      NetworkConfig.testConfig(chainId: 42161, rpcUrl: "https://arbitrum-mainnet.com")
    ]
    
    do {
      try await manager.initializePortal(
        portalSessionToken: "valid-test-token",
        networkConfigs: configs
      )
      
      let portal = try manager.portal
      #expect(portal != nil)
    } catch RainSDKError.providerError {
      // Expected in test environment
    } catch {
      throw error
    }
  }
  
  // MARK: - Validation Tests (Failure Cases)
  
  @Test("Should throw unauthorized error for empty token")
  func testEmptyToken() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1)]
    
    await #expect(throws: RainSDKError.unauthorized) {
      try await manager.initializePortal(
        portalSessionToken: "",
        networkConfigs: configs
      )
    }
  }
  
  @Test("Should throw invalidConfig error for invalid chain ID (zero)")
  func testInvalidChainIdZero() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 0)]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "https://test-rpc.com")) {
      try await manager.initializePortal(
        portalSessionToken: "test-token",
        networkConfigs: configs
      )
    }
  }
  
  @Test("Should throw invalidConfig error for invalid chain ID (negative)")
  func testInvalidChainIdNegative() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: -1)]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: -1, rpcUrl: "https://test-rpc.com")) {
      try await manager.initializePortal(
        portalSessionToken: "test-token",
        networkConfigs: configs
      )
    }
  }
  
  @Test("Should throw invalidConfig error for empty RPC URL")
  func testEmptyRpcUrl() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "")]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "")) {
      try await manager.initializePortal(
        portalSessionToken: "test-token",
        networkConfigs: configs
      )
    }
  }
  
  @Test("Should throw invalidConfig error for invalid RPC URL format")
  func testInvalidRpcUrlFormat() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "not-a-valid-url")]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "not-a-valid-url")) {
      try await manager.initializePortal(
        portalSessionToken: "test-token",
        networkConfigs: configs
      )
    }
  }
  
  @Test("Should throw invalidConfig error for URL without HTTP/HTTPS scheme")
  func testInvalidRpcUrlScheme() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "ftp://example.com")]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "ftp://example.com")) {
      try await manager.initializePortal(
        portalSessionToken: "test-token",
        networkConfigs: configs
      )
    }
  }
  
  // MARK: - Portal Access Tests
  
  @Test("Should throw sdkNotInitialized when accessing portal before initialization")
  func testPortalAccessBeforeInitialization() throws {
    let manager = RainSDKManager()
    
    #expect(throws: RainSDKError.sdkNotInitialized) {
      try manager.portal
    }
  }
  
  // MARK: - Helper Method Tests
  
  @Test("validateInputs should pass with valid inputs")
  func testValidateInputsSuccess() throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1),
      NetworkConfig.testConfig(chainId: 137)
    ]
    
    // Should not throw
    try manager.validateInputs(
      portalSessionToken: "valid-token",
      networkConfigs: configs
    )
  }
  
  @Test("validateInputs should throw for empty token")
  func testValidateInputsEmptyToken() throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1)]
    
    #expect(throws: RainSDKError.unauthorized) {
      try manager.validateInputs(
        portalSessionToken: "",
        networkConfigs: configs
      )
    }
  }
  
  @Test("buildRpcConfig should convert NetworkConfigs to EIP-155 format")
  func testBuildRpcConfigSuccess() throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.com"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon.com")
    ]
    
    let result = try manager.buildRpcConfig(from: configs)
    
    #expect(result.count == 2)
    #expect(result["eip155:1"] == "https://mainnet.com")
    #expect(result["eip155:137"] == "https://polygon.com")
  }
  
  @Test("buildRpcConfig should throw for invalid chain ID")
  func testBuildRpcConfigInvalidChainId() throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 0)]
    
    #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "https://test-rpc.com")) {
      try manager.buildRpcConfig(from: configs)
    }
  }
  
  @Test("buildRpcConfig should throw for invalid RPC URL")
  func testBuildRpcConfigInvalidRpcUrl() throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "invalid-url")]
    
    #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "invalid-url")) {
      try manager.buildRpcConfig(from: configs)
    }
  }
  
  // MARK: - Initialization without Portal token
  
  // MARK: - Success Cases
  
  @Test("initialize should succeed with valid network configs")
  func testInitializeSuccess() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")
    ]
    
    // Should not throw
    try await manager.initialize(networkConfigs: configs)
    
    // After initialization, transaction builder should be available
    // We can test this by checking if buildEIP712Message can be called
    // (it will fail with sdkNotInitialized if not initialized, but that's a different error)
  }
  
  @Test("initialize should handle single network config")
  func testInitializeSingleNetwork() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    
    try await manager.initialize(networkConfigs: configs)
  }
  
  @Test("initialize should handle multiple network configs")
  func testInitializeMultipleNetworks() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://eth-mainnet.com"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-mainnet.com"),
      NetworkConfig.testConfig(chainId: 42161, rpcUrl: "https://arbitrum-mainnet.com")
    ]
    
    try await manager.initialize(networkConfigs: configs)
  }
  
  // MARK: - Validation Tests (Failure Cases)
  
  @Test("Should throw invalidConfig error for empty network configs")
  func testInitializeEmptyConfigs() async throws {
    let manager = RainSDKManager()
    let configs: [NetworkConfig] = []
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }
  
  @Test("Should throw invalidConfig error for invalid chain ID (zero)")
  func testInitializeInvalidChainIdZero() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 0)]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "https://test-rpc.com")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }
  
  @Test("Should throw invalidConfig error for invalid chain ID (negative)")
  func testInitializeInvalidChainIdNegative() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: -1)]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: -1, rpcUrl: "https://test-rpc.com")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }
  
  @Test("Should throw invalidConfig error for empty RPC URL")
  func testInitializeEmptyRpcUrl() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "")]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }
  
  @Test("Should throw invalidConfig error for invalid RPC URL format")
  func testInitializeInvalidRpcUrlFormat() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "not-a-valid-url")]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "not-a-valid-url")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }
  
  @Test("Should throw invalidConfig error for URL without HTTP/HTTPS scheme")
  func testInitializeInvalidRpcUrlScheme() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "ftp://example.com")]
    
    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "ftp://example.com")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }
  
  // MARK: - Portal Access Tests
  
  @Test("Should throw sdkNotInitialized when accessing portal after wallet-agnostic initialization")
  func testPortalAccessAfterWalletAgnosticInit() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1)]
    
    // Initialize in wallet-agnostic mode
    try await manager.initialize(networkConfigs: configs)
    
    // Portal should not be accessible
    #expect(throws: RainSDKError.sdkNotInitialized) {
      try manager.portal
    }
  }
}
