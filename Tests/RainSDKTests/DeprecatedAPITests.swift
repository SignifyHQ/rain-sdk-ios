import Testing
import Foundation
import Web3
import PortalSwift
@testable import RainSDK

/// Locks the 1.0.0 source-compat shims in `Deprecated.swift`: return-type parity, the
/// Double-collapse, verbatim contract-address keying, and delegation to the canonical API.
/// Mirrors the Android `RainSdkManagerDeprecatedApiTest`.
@Suite("Deprecated API Parity")
struct DeprecatedAPITests {
  /// Mixed-case on purpose — proves keys are kept verbatim, not lowercased.
  static let mixedCaseToken = "0xAbCdEf0000000000000000000000000000000001"

  @available(*, deprecated)
  @Test("getNativeBalance collapses the native Balance to a Double and delegates with .native")
  func testGetNativeBalance() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    stub.balanceToReturn = Balance(token: .native, chainId: 1, rawAmount: BigUInt(1_500_000_000_000_000_000), decimals: 18, symbol: "ETH")

    let value: Double = try await manager.getNativeBalance(chainId: 1)

    #expect(value == 1.5)
    #expect(stub.getBalanceCalls.last?.token == .native)
  }

  @available(*, deprecated)
  @Test("getERC20Balance collapses to a Double, ignores decimals, and delegates with .contract")
  func testGetERC20Balance() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    stub.balanceToReturn = Balance(token: .contract(address: Self.mixedCaseToken), chainId: 1, rawAmount: BigUInt(7_000_000), decimals: 6, symbol: "USDC")

    // decimals arg is intentionally wrong — it must be ignored.
    let value: Double = try await manager.getERC20Balance(chainId: 1, tokenAddress: Self.mixedCaseToken, decimals: 999)

    #expect(value == 7.0)
    #expect(stub.getBalanceCalls.last?.token == .contract(address: Self.mixedCaseToken))
  }

  @available(*, deprecated)
  @Test("getBalances returns [String: Double]: native under \"\", contract by verbatim address")
  func testGetBalancesMap() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    stub.balancesByChainId = [1: [
      Balance(token: .native, chainId: 1, rawAmount: BigUInt(1_500_000_000_000_000_000), decimals: 18, symbol: "ETH"),
      Balance(token: .contract(address: Self.mixedCaseToken), chainId: 1, rawAmount: BigUInt(100_000_000), decimals: 6, symbol: "USDC")
    ]]

    let map: [String: Double] = try await manager.getBalances(chainId: 1)

    #expect(map[""] == 1.5)                              // native under empty-string key
    #expect(map[Self.mixedCaseToken] == 100.0)           // verbatim, not lowercased
    #expect(map[Self.mixedCaseToken.lowercased()] == nil)
    #expect(map.count == 2)
    #expect(stub.getBalancesCalls == [1])                // delegated to canonical getTokenBalances
  }

  @available(*, deprecated)
  @Test("getERC20Balances drops native, keeps only contract tokens keyed verbatim")
  func testGetERC20BalancesMap() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    stub.balancesByChainId = [1: [
      Balance(token: .native, chainId: 1, rawAmount: BigUInt(1_500_000_000_000_000_000), decimals: 18, symbol: "ETH"),
      Balance(token: .contract(address: Self.mixedCaseToken), chainId: 1, rawAmount: BigUInt(100_000_000), decimals: 6, symbol: "USDC")
    ]]

    let map: [String: Double] = try await manager.getERC20Balances(chainId: 1)

    #expect(map[""] == nil)
    #expect(map[Self.mixedCaseToken] == 100.0)
    #expect(map.count == 1)
  }

  @available(*, deprecated)
  @Test("sendNativeToken returns the tx hash String and delegates to sendNative")
  func testSendNativeTokenReturnsString() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()
    let expectedHash = "0x" + String(repeating: "a", count: 64)
    stub.sendTransactionHashToReturn = expectedHash

    let hash: String = try await manager.sendNativeToken(
      chainId: 1,
      to: TestFixtures.recipientAddress,
      amount: 1.5
    )

    #expect(hash == expectedHash)
    #expect(stub.sendTransactionCalls.count == 1)
  }

  @available(*, deprecated)
  @Test("composeTransactionParameters returns Portal's ETHTransactionParam mapped from buildTransactionParameters")
  func testComposeTransactionParametersReturnsEthParam() throws {
    let manager = RainSDKManager()

    let param: ETHTransactionParam = manager.composeTransactionParameters(
      walletAddress: TestFixtures.walletAddress,
      contractAddress: TestFixtures.contractAddress,
      transactionData: "0xdeadbeef"
    )
    let canonical = manager.buildTransactionParameters(
      walletAddress: TestFixtures.walletAddress,
      contractAddress: TestFixtures.contractAddress,
      transactionData: "0xdeadbeef"
    )

    #expect(param.from == canonical.from)
    #expect(param.to == canonical.to)
    #expect(param.value == canonical.value)
    #expect(param.data == canonical.data)
  }
}
