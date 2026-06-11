import Testing
import Foundation
import Web3
@testable import PortalSwift
@testable import RainSDK

/// Manager-contract tests for balance APIs: validation, mode guards, and error wrapping.
/// Provider-specific success paths and request-call assertions live in `Adapters/`.
@Suite("Balance Tests")
struct BalanceTests {

  // MARK: - getBalance validation

  @Test("getBalance(.native) throws sdkNotInitialized before initialization")
  func testGetBalanceNativeBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getBalance(chainId: 1, token: .native)
    }
  }

  @Test("getBalance(.contract) throws sdkNotInitialized before initialization")
  func testGetBalanceContractBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getBalance(chainId: 1, token: .contract(address: TestFixtures.usdcAddress))
    }
  }

  @Test("getBalance throws sdkNotInitialized after wallet-agnostic initialize")
  func testGetBalanceAfterWalletAgnosticInit() async throws {
    let manager = try await TestManagers.walletAgnosticManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getBalance(chainId: 1, token: .native)
    }
  }

  @Test("getBalance(.native) throws walletUnavailable when provider has no address")
  func testGetBalanceNativeNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getBalance(chainId: 1, token: .native)
    }
  }

  @Test("getBalance(.contract) throws walletUnavailable when provider has no address")
  func testGetBalanceContractNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getBalance(chainId: 1, token: .contract(address: TestFixtures.usdcAddress))
    }
  }

  // MARK: - getTokenBalances validation

  @Test("getTokenBalances throws sdkNotInitialized before initialization")
  func testGetBalancesBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getTokenBalances(chainId: 1)
    }
  }

  @Test("getTokenBalances throws sdkNotInitialized after wallet-agnostic initialize")
  func testGetBalancesAfterWalletAgnosticInit() async throws {
    let manager = try await TestManagers.walletAgnosticManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getTokenBalances(chainId: 1)
    }
  }

  @Test("getTokenBalances throws walletUnavailable when provider has no address")
  func testGetBalancesNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getTokenBalances(chainId: 1)
    }
  }

  // MARK: - Happy paths via provider-agnostic stub

  @Test("getBalance forwards chain/token to the provider and returns its rich Balance")
  func testGetBalanceRoutesToProvider() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    let expected = Balance(
      token: .contract(address: TestFixtures.usdcAddress),
      chainId: 1,
      rawAmount: BigUInt(7_000_000),
      decimals: 6,
      symbol: "USDC"
    )
    stub.balanceToReturn = expected

    let balance = try await manager.getBalance(
      chainId: 1,
      token: .contract(address: TestFixtures.usdcAddress)
    )

    #expect(balance == expected)
    #expect(balance.decimalAmount == 7)
    #expect(stub.getBalanceCalls.count == 1)
    #expect(stub.getBalanceCalls[0].chainId == 1)
    #expect(stub.getBalanceCalls[0].token == .contract(address: TestFixtures.usdcAddress))
  }

  @Test("getTokenBalances returns whatever the provider returned for the chain")
  func testGetBalancesRoutesToProvider() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    let native = Balance(
      token: .native,
      chainId: 1,
      rawAmount: BigUInt(1_500_000_000_000_000_000),
      decimals: 18,
      symbol: "ETH"
    )
    let usdc = Balance(
      token: .contract(address: TestFixtures.usdcAddress),
      chainId: 1,
      rawAmount: BigUInt(100_000_000),
      decimals: 6,
      symbol: "USDC"
    )
    stub.balancesByChainId = [1: [native, usdc]]

    let balances = try await manager.getTokenBalances(chainId: 1)

    #expect(balances == [native, usdc])
    #expect(stub.getBalancesCalls == [1])
  }

  // MARK: - getAllBalances

  @Test("getAllBalances throws sdkNotInitialized before any provider is set")
  func testGetAllBalancesBeforeInit() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.getAllBalances()
    }
  }

  @Test("getAllBalances returns a flat list spanning every configured chain")
  func testGetAllBalancesHappyPath() async throws {
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://eth"),
      NetworkConfig.testConfig(chainId: 43114, rpcUrl: "https://avax"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon")
    ]
    let (manager, stub) = try await TestManagers.stubProviderManager(configs: configs)
    let eth = Balance(token: .native, chainId: 1, rawAmount: BigUInt(1_000_000_000_000_000_000), decimals: 18, symbol: "ETH")
    let ethUsdc = Balance(token: .contract(address: TestFixtures.usdcAddress), chainId: 1, rawAmount: BigUInt(100_000_000), decimals: 6, symbol: "USDC")
    let avax = Balance(token: .native, chainId: 43114, rawAmount: BigUInt(2_000_000_000_000_000_000), decimals: 18, symbol: "AVAX")
    let pol = Balance(token: .native, chainId: 137, rawAmount: BigUInt(100_000_000_000_000_000), decimals: 18, symbol: "POL")
    stub.balancesByChainId = [
      1: [eth, ethUsdc],
      43114: [avax],
      137: [pol]
    ]

    let all = try await manager.getAllBalances()

    #expect(all.count == 4)
    #expect(all.contains(eth))
    #expect(all.contains(ethUsdc))
    #expect(all.contains(avax))
    #expect(all.contains(pol))
  }

  @Test("getAllBalances tolerates a failing chain — it contributes no entries")
  func testGetAllBalancesPartialFailure() async throws {
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://eth"),
      NetworkConfig.testConfig(chainId: 43114, rpcUrl: "https://broken-avax")
    ]
    let (manager, stub) = try await TestManagers.stubProviderManager(configs: configs)
    let eth = Balance(token: .native, chainId: 1, rawAmount: BigUInt(1_000_000_000_000_000_000), decimals: 18, symbol: "ETH")
    stub.balancesByChainId = [1: [eth]]
    stub.errorsByChainId = [
      43114: RainSDKError.networkError(underlying: NSError(domain: "x", code: 0))
    ]

    let all = try await manager.getAllBalances()

    #expect(all.count == 1)
    #expect(all.contains(eth))
    #expect(!all.contains { $0.chainId == 43114 })
  }
}
