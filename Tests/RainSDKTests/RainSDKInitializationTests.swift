import Testing
import Foundation
@testable import RainSDK

@Suite("SDK Initialization Tests")
struct SDKInitializationTests {

  // MARK: - initializePortal validation

  @Test("initializePortal throws unauthorized for empty token")
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

  @Test("initializePortal throws invalidConfig for zero chain ID")
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

  @Test("initializePortal throws invalidConfig for negative chain ID")
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

  @Test("initializePortal throws invalidConfig for empty RPC URL")
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

  @Test("initializePortal throws invalidConfig for URL without scheme")
  func testRpcUrlMissingScheme() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "not-a-valid-url")]

    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "not-a-valid-url")) {
      try await manager.initializePortal(
        portalSessionToken: "test-token",
        networkConfigs: configs
      )
    }
  }

  @Test("initializePortal throws invalidConfig for non-HTTP scheme")
  func testRpcUrlNonHttpScheme() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "ftp://example.com")]

    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "ftp://example.com")) {
      try await manager.initializePortal(
        portalSessionToken: "test-token",
        networkConfigs: configs
      )
    }
  }

  // MARK: - Provider access before init

  @Test("portal access before initialization throws sdkNotInitialized")
  func testPortalAccessBeforeInitialization() throws {
    let manager = RainSDKManager()

    #expect(throws: RainSDKError.sdkNotInitialized) {
      try manager.portal
    }
  }

  @Test("turnkey access before initialization throws sdkNotInitialized")
  func testTurnkeyAccessBeforeInitialization() throws {
    let manager = RainSDKManager()

    #expect(throws: RainSDKError.sdkNotInitialized) {
      try manager.turnkey
    }
  }

  // MARK: - Validation helpers

  @Test("validateInputs passes with valid inputs")
  func testValidateInputsSuccess() throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1),
      NetworkConfig.testConfig(chainId: 137)
    ]

    try manager.validateInputs(
      portalSessionToken: "valid-token",
      networkConfigs: configs
    )
  }

  @Test("validateInputs throws unauthorized for empty token")
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

  @Test("buildRpcConfig converts NetworkConfigs to EIP-155 format")
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

  @Test("buildRpcConfig throws for invalid chain ID")
  func testBuildRpcConfigInvalidChainId() throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 0)]

    #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "https://test-rpc.com")) {
      try manager.buildRpcConfig(from: configs)
    }
  }

  @Test("buildRpcConfig throws for invalid RPC URL")
  func testBuildRpcConfigInvalidRpcUrl() throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "invalid-url")]

    #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "invalid-url")) {
      try manager.buildRpcConfig(from: configs)
    }
  }

  // MARK: - Wallet-agnostic initialize

  @Test("initialize succeeds with valid configs")
  func testInitializeSuccess() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")
    ]

    try await manager.initialize(networkConfigs: configs)
  }

  @Test("initialize throws invalidConfig for empty configs")
  func testInitializeEmptyConfigs() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "")) {
      try await manager.initialize(networkConfigs: [])
    }
  }

  @Test("initialize throws invalidConfig for zero chain ID")
  func testInitializeInvalidChainIdZero() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 0)]

    await #expect(throws: RainSDKError.invalidConfig(chainId: 0, rpcUrl: "https://test-rpc.com")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }

  @Test("initialize throws invalidConfig for empty RPC URL")
  func testInitializeEmptyRpcUrl() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "")]

    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }

  @Test("initialize throws invalidConfig for URL without scheme")
  func testInitializeRpcUrlMissingScheme() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "not-a-valid-url")]

    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "not-a-valid-url")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }

  @Test("initialize throws invalidConfig for non-HTTP scheme")
  func testInitializeRpcUrlNonHttpScheme() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "ftp://example.com")]

    await #expect(throws: RainSDKError.invalidConfig(chainId: 1, rpcUrl: "ftp://example.com")) {
      try await manager.initialize(networkConfigs: configs)
    }
  }

  @Test("portal access after wallet-agnostic initialize throws sdkNotInitialized")
  func testPortalAccessAfterWalletAgnosticInit() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1)]
    try await manager.initialize(networkConfigs: configs)

    #expect(throws: RainSDKError.sdkNotInitialized) {
      try manager.portal
    }
  }

  // MARK: - Turnkey test seam

  @Test("Turnkey test initializer wires a Turnkey-backed wallet provider")
  func testTurnkeyInitializerSuccess() async throws {
    let (manager, _, _) = TestManagers.turnkeyManager()

    let walletAddress = try await manager.getWalletAddress()
    #expect(walletAddress == MockTurnkey.defaultWalletAddress)
  }
}
