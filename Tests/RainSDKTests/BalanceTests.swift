import Testing
import Foundation
@testable import PortalSwift
@testable import RainSDK

/// Manager-contract tests for balance APIs: validation, mode guards, and error wrapping.
/// Provider-specific success paths and request-call assertions live in `Adapters/`.
@Suite("Balance Tests")
struct BalanceTests {

  // MARK: - getNativeBalance

  @Test("getNativeBalance throws walletUnavailable before initialization")
  func testGetNativeBalanceBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  @Test("getNativeBalance throws walletUnavailable after wallet-agnostic initialize")
  func testGetNativeBalanceAfterWalletAgnosticInit() async throws {
    let manager = try await TestManagers.walletAgnosticManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  @Test("getNativeBalance throws walletUnavailable when provider has no address")
  func testGetNativeBalanceNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getNativeBalance(chainId: 1)
    }
  }

  // MARK: - getERC20Balance

  @Test("getERC20Balance throws walletUnavailable before initialization")
  func testGetERC20BalanceBeforeInitialization() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balance(chainId: 1, tokenAddress: TestFixtures.usdcAddress)
    }
  }

  @Test("getERC20Balance throws walletUnavailable after wallet-agnostic initialize")
  func testGetERC20BalanceAfterWalletAgnosticInit() async throws {
    let manager = try await TestManagers.walletAgnosticManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balance(chainId: 1, tokenAddress: TestFixtures.usdcAddress)
    }
  }

  @Test("getERC20Balance throws walletUnavailable when provider has no address")
  func testGetERC20BalanceNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balance(chainId: 1, tokenAddress: TestFixtures.usdcAddress)
    }
  }

  // MARK: - getERC20Balances / getBalances

  @Test("getERC20Balances throws walletUnavailable when no provider")
  func testGetERC20BalancesNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getERC20Balances(chainId: 1)
    }
  }

  @Test("getBalances throws walletUnavailable when no provider")
  func testGetBalancesNoProvider() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getBalances(chainId: 1)
    }
  }

  // MARK: - Happy paths via provider-agnostic stub

  @Test("getNativeBalance returns whatever the provider returned")
  func testGetNativeBalanceRoutesToProvider() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    stub.nativeBalanceToReturn = 42.5

    let balance = try await manager.getNativeBalance(chainId: 1)
    #expect(balance == 42.5)
  }

  @Test("getERC20Balance forwards token/chain/decimals to the provider and returns its result")
  func testGetERC20BalanceRoutesToProvider() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    stub.erc20BalanceToReturn = 7.0

    let balance = try await manager.getERC20Balance(
      chainId: 1,
      tokenAddress: TestFixtures.usdcAddress,
      decimals: 6
    )

    #expect(balance == 7.0)
    #expect(stub.getERC20BalanceCalls.count == 1)
    #expect(stub.getERC20BalanceCalls[0].chainId == 1)
    #expect(stub.getERC20BalanceCalls[0].tokenAddress == TestFixtures.usdcAddress)
    #expect(stub.getERC20BalanceCalls[0].decimals == 6)
  }

  @Test("getERC20Balances returns whatever the provider returned")
  func testGetERC20BalancesRoutesToProvider() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    stub.erc20BalancesToReturn = [TestFixtures.usdcAddress: 100.0]

    let balances = try await manager.getERC20Balances(chainId: 1)
    #expect(balances == [TestFixtures.usdcAddress: 100.0])
  }

  @Test("getBalances merges native balance under empty key with ERC-20 balances")
  func testGetBalancesMergesNativeAndERC20() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    stub.nativeBalanceToReturn = 1.5
    stub.erc20BalancesToReturn = [TestFixtures.usdcAddress: 100.0]

    let balances = try await manager.getBalances(chainId: 1)
    #expect(balances[""] == 1.5)
    #expect(balances[TestFixtures.usdcAddress] == 100.0)
  }

  // MARK: - getAllBalances

  @Test("getAllBalances throws walletUnavailable before any provider is set")
  func testGetAllBalancesBeforeInit() async throws {
    let manager = RainSDKManager()
    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.getAllBalances()
    }
  }

  @Test("getAllBalances returns per-chain native + ERC-20 maps for every configured chain")
  func testGetAllBalancesHappyPath() async throws {
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://eth"),
      NetworkConfig.testConfig(chainId: 43114, rpcUrl: "https://avax"),
      NetworkConfig.testConfig(chainId: 137, rpcUrl: "https://polygon")
    ]
    let (manager, stub) = try await TestManagers.stubProviderManager(configs: configs)
    stub.nativeBalanceByChainId = [1: 1.0, 43114: 2.5, 137: 0.1]
    stub.erc20BalancesByChainId = [
      1: [TestFixtures.usdcAddress: 100.0],
      43114: [TestFixtures.usdcAddress: 50.0],
      137: [:]
    ]

    let all = try await manager.getAllBalances()

    #expect(all.count == 3)
    #expect(all[1]?[""] == 1.0)
    #expect(all[1]?[TestFixtures.usdcAddress] == 100.0)
    #expect(all[43114]?[""] == 2.5)
    #expect(all[43114]?[TestFixtures.usdcAddress] == 50.0)
    #expect(all[137]?[""] == 0.1)
    #expect(all[137]?.count == 1) // only native; no ERC-20s
  }

  @Test("getAllBalances collapses a chain to [:] when both native and ERC-20 fetches fail")
  func testGetAllBalancesPartialFailure() async throws {
    let configs = [
      NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://eth"),
      NetworkConfig.testConfig(chainId: 43114, rpcUrl: "https://broken-avax")
    ]
    let (manager, stub) = try await TestManagers.stubProviderManager(configs: configs)
    stub.nativeBalanceByChainId = [1: 1.0]
    stub.erc20BalancesByChainId = [1: [TestFixtures.usdcAddress: 100.0]]
    stub.errorsByChainId = [
      43114: RainSDKError.networkError(underlying: NSError(domain: "x", code: 0))
    ]

    let all = try await manager.getAllBalances()

    #expect(all.count == 2)
    #expect(all[1]?[""] == 1.0)
    #expect(all[1]?[TestFixtures.usdcAddress] == 100.0)
    // Both sides failed — chain appears as an empty entry the caller can detect.
    #expect(all[43114] == [:])
  }

  @Test("getAllBalances preserves native balance when ERC-20 fetch fails on the same chain")
  func testGetAllBalancesPreservesNativeOnErc20Failure() async throws {
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://eth")]
    let (manager, stub) = try await TestManagers.stubProviderManager(configs: configs)
    stub.nativeBalanceByChainId = [1: 1.5]
    stub.erc20ErrorsByChainId = [
      1: RainSDKError.networkError(underlying: NSError(domain: "x", code: 0))
    ]

    let all = try await manager.getAllBalances()

    // ERC-20 fetch threw, native succeeded — native is still returned.
    #expect(all[1]?[""] == 1.5)
    #expect(all[1]?.count == 1)
  }

  @Test("getAllBalances preserves ERC-20 balances when native fetch fails on the same chain")
  func testGetAllBalancesPreservesErc20OnNativeFailure() async throws {
    let configs = [NetworkConfig.testConfig(chainId: 1, rpcUrl: "https://eth")]
    let (manager, stub) = try await TestManagers.stubProviderManager(configs: configs)
    stub.erc20BalancesByChainId = [1: [TestFixtures.usdcAddress: 42.0]]
    stub.nativeErrorsByChainId = [
      1: RainSDKError.networkError(underlying: NSError(domain: "x", code: 0))
    ]

    let all = try await manager.getAllBalances()

    // Native threw, ERC-20 succeeded — ERC-20s are still returned, no `""` key.
    #expect(all[1]?[TestFixtures.usdcAddress] == 42.0)
    #expect(all[1]?[""] == nil)
  }
}
