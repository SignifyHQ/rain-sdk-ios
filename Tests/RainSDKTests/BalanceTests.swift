import Testing
import Foundation
@testable import PortalSwift
@testable import RainSDK

@Suite("Balance Tests")
struct BalanceTests {

  private static let walletAddress = "0x1234567890123456789012345678901234567890"
  private static let tokenAddress  = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
  private static let configs       = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/test")]

  /// Returns a mock portal with the default wallet address set.
  private static func makePortal() -> MockPortal {
    let portal = MockPortal()
    portal.setMockAddress(walletAddress, forNamespace: PortalNamespace.eip155)
    return portal
  }

  /// Returns a manager wired with a mock portal + mock builder (no real network calls).
  private static func makeManager(portal: MockPortal? = nil) -> RainSDKManager {
    let p = portal ?? makePortal()
    let builder = MockTransactionBuilderService(networkConfigs: configs)
    return RainSDKManager(portal: p, transactionBuilder: builder)
  }

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
    try await manager.initialize(networkConfigs: Self.configs)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  @Test("getNativeBalance should throw walletUnavailable when no wallet address from provider")
  func testGetNativeBalanceNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let manager = Self.makeManager(portal: mockPortal)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  @Test("getNativeBalance success returns 1.0 ETH and calls eth_getBalance on the correct chain")
  func testGetNativeBalanceSuccess() async throws {
    let manager = Self.makeManager()

    let balance = try await manager.getNativeBalance(chainId: 1)

    #expect(balance == 1.0)
    #expect(MockPortal().requestCalls.isEmpty == true) // sanity: new instance has no calls
    let portal = MockPortal()
    portal.setMockAddress(Self.walletAddress, forNamespace: PortalNamespace.eip155)
    let builder = MockTransactionBuilderService(networkConfigs: Self.configs)
    let tracked = RainSDKManager(portal: portal, transactionBuilder: builder)
    _ = try await tracked.getNativeBalance(chainId: 1)
    #expect(portal.requestCalls.count == 1)
    #expect(portal.requestCalls[0].method == .eth_getBalance)
    #expect(portal.requestCalls[0].chainId == "eip155:1")
  }

  // MARK: - getERC20Balance (via RPC eth_call)

  @Test("getERC20Balance should throw walletUnavailable when called before initialization")
  func testGetERC20BalanceBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balance(chainId: 1, tokenAddress: Self.tokenAddress)
    }
  }

  @Test("getERC20Balance should throw walletUnavailable after wallet-agnostic initialize")
  func testGetERC20BalanceAfterWalletAgnosticInit() async throws {
    let manager = RainSDKManager()
    try await manager.initialize(networkConfigs: Self.configs)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balance(chainId: 1, tokenAddress: Self.tokenAddress)
    }
  }

  @Test("getERC20Balance should throw walletUnavailable when no wallet address from provider")
  func testGetERC20BalanceNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let manager = Self.makeManager(portal: mockPortal)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balance(chainId: 1, tokenAddress: Self.tokenAddress)
    }
  }

  @Test("getERC20Balance returns 0 when eth_call returns empty result")
  func testGetERC20BalanceReturnsZeroWhenCallReturnsEmpty() async throws {
    // No mock set for eth_call → portal returns nil → extractHexString returns "0x0" → 0.0
    let balance = try await Self.makeManager().getERC20Balance(
      chainId: 1,
      tokenAddress: Self.tokenAddress
    )
    #expect(balance == 0.0)
  }

  @Test("getERC20Balance success returns correct balance using default 18 decimals")
  func testGetERC20BalanceSuccessDefaultDecimals() async throws {
    let mockPortal = Self.makePortal()
    // 1 token with 18 decimals = 0x0de0b6b3a7640000 (1_000_000_000_000_000_000)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      result: PortalProviderRpcResponse(jsonrpc: "2.0", result: "0x0de0b6b3a7640000")
    )
    let builder = MockTransactionBuilderService(networkConfigs: Self.configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: builder)

    let balance = try await manager.getERC20Balance(chainId: 1, tokenAddress: Self.tokenAddress)

    #expect(balance == 1.0)
    #expect(mockPortal.requestCalls.count == 1)
    #expect(mockPortal.requestCalls[0].method == .eth_call)
    #expect(mockPortal.requestCalls[0].chainId == "eip155:1")
  }

  @Test("getERC20Balance success returns correct balance with custom 6 decimals (e.g. USDC)")
  func testGetERC20BalanceSuccessCustomDecimals() async throws {
    let mockPortal = Self.makePortal()
    // 1 USDC with 6 decimals = 0x0F4240 (1_000_000)
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      result: PortalProviderRpcResponse(jsonrpc: "2.0", result: "0x0F4240")
    )
    let builder = MockTransactionBuilderService(networkConfigs: Self.configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: builder)

    let balance = try await manager.getERC20Balance(
      chainId: 1,
      tokenAddress: Self.tokenAddress,
      decimals: 6
    )

    #expect(balance == 1.0)
  }

  @Test("getERC20Balance with nil decimals defaults to 18")
  func testGetERC20BalanceNilDecimalsDefaultsTo18() async throws {
    let mockPortal = Self.makePortal()
    // 2.5 tokens with 18 decimals = 2_500_000_000_000_000_000 = 0x22B1C8C1227A00000
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      result: PortalProviderRpcResponse(jsonrpc: "2.0", result: "0x22B1C8C1227A00000")
    )
    let builder = MockTransactionBuilderService(networkConfigs: Self.configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: builder)

    // nil decimals → uses defaultDecimals (18)
    let balance = try await manager.getERC20Balance(
      chainId: 1,
      tokenAddress: Self.tokenAddress,
      decimals: nil
    )

    #expect(balance == 2.5)
  }

  @Test("getERC20Balance throws providerError when portal request fails")
  func testGetERC20BalancePortalError() async throws {
    let mockPortal = Self.makePortal()
    mockPortal.setMockResponse(
      chainId: "eip155:1",
      method: .eth_call,
      error: NSError(domain: "RPC", code: -1, userInfo: [NSLocalizedDescriptionKey: "RPC error"])
    )
    let builder = MockTransactionBuilderService(networkConfigs: Self.configs)
    let manager = RainSDKManager(portal: mockPortal, transactionBuilder: builder)

    await #expect(throws: RainSDKError.providerError(underlying: NSError())) {
      _ = try await manager.getERC20Balance(chainId: 1, tokenAddress: Self.tokenAddress)
    }
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
    let mockPortal = Self.makePortal()
    mockPortal.mockAssetsResponse = Self.emptyAssetsResponse()
    let manager = Self.makeManager(portal: mockPortal)

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
    let mockPortal = Self.makePortal()
    mockPortal.mockAssetsResponse = Self.emptyAssetsResponse()
    let manager = Self.makeManager(portal: mockPortal)

    let balances = try await manager.getBalances(chainId: 1)
    #expect(balances[""] == 1.0)
    #expect(balances.keys.contains(""))
  }
}
