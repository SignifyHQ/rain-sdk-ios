import Testing
import Foundation
import Web3
import PortalSwift
@testable import RainCore
@testable import RainPortal

/// Locks the 1.0.0 source-compat shims: return-type parity, the Double-collapse, verbatim
/// contract-address keying, and delegation to the canonical API. The balance/send shims live on
/// `RainClient` (RainCore); `composeTransactionParameters` lives on `RainSdk` in `RainPortal`.
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
  @Test("Double-amount send shims convert via the printed form: 0.1 is exact, not the float error")
  func testDoubleAmountShimExactness() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()

    // With a naive Decimal(0.1) the full binary float error would exceed 18 decimal places and
    // toBaseUnits would throw invalidAmount; the shim must parse the printed "0.1" instead.
    _ = try await manager.sendNativeToken(chainId: 1, to: TestFixtures.recipientAddress, amount: 0.1)

    // 0.1 ETH = 10^17 wei = 0x16345785d8a0000
    #expect(stub.sendTransactionCalls.last?.params.value == "0x16345785d8a0000")
  }

  @available(*, deprecated)
  @Test("sendNativeToken with a NaN amount throws invalidAmount and never sends")
  func testSendNativeTokenNaNAmount() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()

    await #expect(throws: RainSDKError.invalidAmount(amount: "", reason: "")) {
      _ = try await manager.sendNativeToken(
        chainId: 1,
        to: TestFixtures.recipientAddress,
        amount: Double.nan
      )
    }
    #expect(stub.sendTransactionCalls.isEmpty)
  }

  @available(*, deprecated)
  @Test("sendToken with a NaN amount throws invalidAmount and never sends")
  func testSendTokenNaNAmount() async throws {
    let (manager, stub) = try await TestManagers.stubProviderManager()

    await #expect(throws: RainSDKError.invalidAmount(amount: "", reason: "")) {
      _ = try await manager.sendToken(
        chainId: 1,
        contractAddress: Self.mixedCaseToken,
        to: TestFixtures.recipientAddress,
        amount: Double.nan,
        decimals: 6
      )
    }
    #expect(stub.sendTransactionCalls.isEmpty)
  }

  @available(*, deprecated)
  @Test("composeTransactionParameters returns Portal's ETHTransactionParam mapped from buildTransactionParameters")
  func testComposeTransactionParametersReturnsEthParam() throws {
    let rain = try TestManagers.rainSdk()

    let param: ETHTransactionParam = rain.composeTransactionParameters(
      walletAddress: TestFixtures.walletAddress,
      contractAddress: TestFixtures.contractAddress,
      transactionData: "0xdeadbeef"
    )
    let canonical = rain.buildTransactionParameters(
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
