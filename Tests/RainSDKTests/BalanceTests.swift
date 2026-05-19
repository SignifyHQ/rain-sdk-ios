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
}
