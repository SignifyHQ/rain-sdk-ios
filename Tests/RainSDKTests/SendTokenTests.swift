import Testing
import Foundation
import PortalSwift
@testable import RainSDK

@Suite("Send Token Tests")
struct SendTokenTests {

  // MARK: - sendNativeToken

  @Test("sendNativeToken should throw walletUnavailable when called before initialization")
  func testSendNativeTokenBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.sendNativeToken(
        chainId: 1,
        to: "0xrecipient0000000000000000000000000000000000",
        amount: 1.0
      )
    }
  }

  @Test("sendNativeToken should throw walletUnavailable after wallet-agnostic initialize")
  func testSendNativeTokenAfterWalletAgnosticInit() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    try await manager.initialize(networkConfigs: configs)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.sendNativeToken(
        chainId: 1,
        to: "0xrecipient0000000000000000000000000000000000",
        amount: 1.0
      )
    }
  }

  @Test("sendNativeToken should throw walletUnavailable when no wallet address from provider")
  func testSendNativeTokenNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()

    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.sendNativeToken(
        chainId: 1,
        to: "0xrecipient0000000000000000000000000000000000",
        amount: 1.0
      )
    }
  }

  @Test("sendNativeToken success returns tx hash when provider is configured")
  func testSendNativeTokenSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)

    let chainIdString = "eip155:1"
    let mockTxHash = "0x" + String(repeating: "b", count: 64)
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_sendTransaction,
      result: mockTxHash
    )

    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let toAddress = "0xrecipient0000000000000000000000000000000000"
    let txHash = try await manager.sendNativeToken(
      chainId: 1,
      to: toAddress,
      amount: 1.5
    )

    #expect(!txHash.isEmpty)
    #expect(txHash.hasPrefix("0x"))
    #expect(txHash == mockTxHash)
    #expect(mockPortal.requestCalls.count == 1)
    #expect(mockPortal.requestCalls[0].method == .eth_sendTransaction)
    #expect(mockPortal.requestCalls[0].chainId == chainIdString)
  }

  // MARK: - sendERC20Token

  @Test("sendERC20Token should throw sdkNotInitialized when called before initialization")
  func testSendERC20TokenBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.sendERC20Token(
        chainId: 1,
        contractAddress: "0xcontract000000000000000000000000000000000",
        to: "0xrecipient0000000000000000000000000000000000",
        amount: 100.0,
        decimals: 18
      )
    }
  }

  @Test("sendERC20Token should throw walletUnavailable after wallet-agnostic initialize")
  func testSendERC20TokenAfterWalletAgnosticInit() async throws {
    let manager = RainSDKManager()
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    try await manager.initialize(networkConfigs: configs)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.sendERC20Token(
        chainId: 1,
        contractAddress: "0xcontract000000000000000000000000000000000",
        to: "0xrecipient0000000000000000000000000000000000",
        amount: 100.0,
        decimals: 18
      )
    }
  }

  @Test("sendERC20Token should throw walletUnavailable when no wallet address from provider")
  func testSendERC20TokenNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()

    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.sendERC20Token(
        chainId: 1,
        contractAddress: "0xcontract000000000000000000000000000000000",
        to: "0xrecipient0000000000000000000000000000000000",
        amount: 100.0,
        decimals: 18
      )
    }
  }

  @Test("sendERC20Token success returns tx hash when mocks are configured")
  func testSendERC20TokenSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)

    let chainIdString = "eip155:1"
    let mockTxHash = "0x" + String(repeating: "c", count: 64)
    mockPortal.setMockResponse(
      chainId: chainIdString,
      method: .eth_sendTransaction,
      result: mockTxHash
    )

    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")
    ]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let contractAddress = "0xcontract000000000000000000000000000000000"
    let toAddress = "0xrecipient0000000000000000000000000000000000"
    let txHash = try await manager.sendERC20Token(
      chainId: 1,
      contractAddress: contractAddress,
      to: toAddress,
      amount: 100.0,
      decimals: 6
    )

    #expect(!txHash.isEmpty)
    #expect(txHash.hasPrefix("0x"))
    #expect(txHash == mockTxHash)
    #expect(mockPortal.requestCalls.count == 1)
    #expect(mockPortal.requestCalls[0].method == .eth_sendTransaction)
    #expect(mockPortal.requestCalls[0].chainId == chainIdString)
  }
}
