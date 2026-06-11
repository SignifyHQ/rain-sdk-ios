import Testing
import Foundation
@testable import RainSDK

/// Manager-contract tests for send APIs: validation, mode guards, error wrapping.
/// Provider-specific success paths live in `Adapters/`.
@Suite("Send Token Tests")
struct SendTokenTests {

  // MARK: - sendNativeToken

  @Test("sendNativeToken throws sdkNotInitialized before initialization")
  func testSendNativeTokenBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.sendNativeToken(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: 1.0
      )
    }
  }

  @Test("sendNativeToken throws sdkNotInitialized after wallet-agnostic initialize")
  func testSendNativeTokenAfterWalletAgnosticInit() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.sendNativeToken(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: 1.0
      )
    }
  }

  @Test("sendNativeToken throws walletUnavailable when provider has no address")
  func testSendNativeTokenNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.sendNativeToken(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: 1.0
      )
    }
  }

  // MARK: - sendToken

  @Test("sendToken throws sdkNotInitialized before initialization")
  func testSendERC20TokenBeforeInitialization() async throws {
    let manager = RainSDKManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.sendToken(
        chainId: 1,
        contractAddress: TestFixtures.tokenAddress,
        to: TestFixtures.recipientAddress,
        amount: 100.0,
        decimals: 18
      )
    }
  }

  @Test("sendToken throws sdkNotInitialized after wallet-agnostic initialize")
  func testSendERC20TokenAfterWalletAgnosticInit() async throws {
    let manager = try await TestManagers.walletAgnosticManager()

    await #expect(throws: RainSDKError.sdkNotInitialized) {
      _ = try await manager.sendToken(
        chainId: 1,
        contractAddress: TestFixtures.tokenAddress,
        to: TestFixtures.recipientAddress,
        amount: 100.0,
        decimals: 18
      )
    }
  }

  @Test("sendToken throws walletUnavailable when provider has no address")
  func testSendERC20TokenNoWalletAddress() async throws {
    let mockPortal = MockPortal()
    mockPortal.mockAddresses.removeAll()
    let (manager, _, _) = TestManagers.portalManager(portal: mockPortal)

    await #expect(throws: RainSDKError.walletUnavailable) {
      _ = try await manager.sendToken(
        chainId: 1,
        contractAddress: TestFixtures.tokenAddress,
        to: TestFixtures.recipientAddress,
        amount: 100.0,
        decimals: 18
      )
    }
  }

  // MARK: - Happy paths via provider-agnostic stub

  @Test("sendNativeToken returns provider tx hash and forwards from/to/value to the provider")
  func testSendNativeTokenRoutesToProvider() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    let expectedHash = "0x" + String(repeating: "a", count: 64)
    stub.sendTransactionHashToReturn = expectedHash

    let result = try await manager.sendNativeToken(
      chainId: 1,
      to: TestFixtures.recipientAddress,
      amount: 1.5
    )

    #expect(result.transactionHash == expectedHash)
    #expect(stub.sendTransactionCalls.count == 1)
    #expect(stub.sendTransactionCalls[0].chainId == 1)
    #expect(stub.sendTransactionCalls[0].params.from == TestFixtures.walletAddress)
    #expect(stub.sendTransactionCalls[0].params.to == TestFixtures.recipientAddress)
    // Empty data for native transfers.
    #expect(stub.sendTransactionCalls[0].params.data == .empty)
  }

  @Test("sendToken returns provider tx hash and routes calldata to the token contract")
  func testSendERC20TokenRoutesToProvider() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    let expectedHash = "0x" + String(repeating: "b", count: 64)
    stub.sendTransactionHashToReturn = expectedHash

    let result = try await manager.sendToken(
      chainId: 1,
      contractAddress: TestFixtures.tokenAddress,
      to: TestFixtures.recipientAddress,
      amount: 100.0,
      decimals: 6
    )

    #expect(result.transactionHash == expectedHash)
    #expect(stub.sendTransactionCalls.count == 1)
    // ERC-20 transactions target the token contract; recipient is encoded in calldata.
    #expect(stub.sendTransactionCalls[0].params.to == TestFixtures.tokenAddress)
    #expect(stub.sendTransactionCalls[0].params.data.hasPrefix("0x"))
  }

  // MARK: - Deprecated alias (1.0.0 source compat)

  @available(*, deprecated)
  @Test("deprecated sendERC20Token forwards to sendToken and returns the tx hash string")
  func testDeprecatedSendERC20TokenForwards() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    let expectedHash = "0x" + String(repeating: "c", count: 64)
    stub.sendTransactionHashToReturn = expectedHash

    let hash: String = try await manager.sendERC20Token(
      chainId: 1,
      contractAddress: TestFixtures.tokenAddress,
      to: TestFixtures.recipientAddress,
      amount: 100.0,
      decimals: 6
    )

    #expect(hash == expectedHash)
    #expect(stub.sendTransactionCalls[0].params.to == TestFixtures.tokenAddress)
  }
}
