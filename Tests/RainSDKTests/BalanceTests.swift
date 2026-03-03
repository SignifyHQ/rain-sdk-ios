import Testing
import Foundation
@testable import PortalSwift
@testable import RainSDK

@Suite("Balance Tests")
struct BalanceTests {

  /// Empty assets response (no ERC-20 tokens). Use when testing balance APIs with no token list.
  private static func emptyAssetsResponse() -> AssetsResponse {
    AssetsResponse(nativeBalance: nil, tokenBalances: nil, nfts: nil)
  }

  // MARK: - getNativeBalance

  @Test("getNativeBalance should throw walletUnavailable when called before initialization")
  func testGetNativeBalanceBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  @Test("getNativeBalance should throw walletUnavailable after wallet-agnostic initialize")
  func testGetNativeBalanceAfterWalletAgnosticInit() async throws {
    let manager = RainSDKManager()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    try await manager.initialize(networkConfigs: configs)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  @Test("getNativeBalance should throw walletUnavailable when no wallet address from provider")
  func testGetNativeBalanceNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  @Test("getNativeBalance success returns balance when provider returns valid eth_getBalance response")
  func testGetNativeBalanceSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let balance = try await manager.getNativeBalance(chainId: 1)
    #expect(balance == 1.0)
    #expect(mockPortal.requestCalls.count == 1)
    #expect(mockPortal.requestCalls[0].method == .eth_getBalance)
    #expect(mockPortal.requestCalls[0].chainId == "eip155:1")
  }

  // MARK: - getERC20Balance

  @Test("getERC20Balance should throw walletUnavailable when no provider")
  func testGetERC20BalanceNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balance(
        chainId: 1,
        tokenAddress: "0xcontract000000000000000000000000000000000"
      )
    }
  }

  @Test("getERC20Balance returns nil when token is not in balance list")
  func testGetERC20BalanceReturnsNilWhenTokenNotInList() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAssetsResponse = Self.emptyAssetsResponse()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let balance = try await manager.getERC20Balance(
      chainId: 1,
      tokenAddress: "0xcontract000000000000000000000000000000000"
    )
    #expect(balance == nil)
  }

  // MARK: - getERC20Balances

  @Test("getERC20Balances should throw walletUnavailable when no provider")
  func testGetERC20BalancesNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balances(chainId: 1)
    }
  }

  @Test("getERC20Balances success returns empty dictionary when no tokens")
  func testGetERC20BalancesSuccessEmpty() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAssetsResponse = Self.emptyAssetsResponse()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let balances = try await manager.getERC20Balances(chainId: 1)
    #expect(balances.isEmpty)
  }

  // MARK: - getBalances

  @Test("getBalances should throw walletUnavailable when no provider")
  func testGetBalancesNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getBalances(chainId: 1)
    }
  }

  @Test("getBalances success returns native under empty key and ERC-20 entries")
  func testGetBalancesSuccess() async throws {
    let mockPortal = MockPortal()
    mockPortal.setMockAddress("0x1234567890123456789012345678901234567890", forNamespace: PortalNamespace.eip155)
    mockPortal.mockAssetsResponse = Self.emptyAssetsResponse()
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]
    let mockBuilder = MockTransactionBuilderService(networkConfigs: configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: mockBuilder)

    let balances = try await manager.getBalances(chainId: 1)
    #expect(balances[""] == 1.0)
    #expect(balances.keys.contains(""))
  }
}
