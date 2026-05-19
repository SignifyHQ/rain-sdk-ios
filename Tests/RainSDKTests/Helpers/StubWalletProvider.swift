import Foundation
@testable import RainSDK

/// Provider-agnostic stub for manager-contract tests. Returns configured values and
/// records calls — use when a test only needs to prove the manager routes to the
/// provider and returns the provider's result, without invoking Portal- or Turnkey-specific behavior.
final class StubWalletProvider: RainWalletProvider, @unchecked Sendable {
  var addressToReturn: String = TestFixtures.walletAddress
  var nativeBalanceToReturn: Double = 0
  var erc20BalanceToReturn: Double = 0
  var erc20BalancesToReturn: [String: Double] = [:]
  var transactionsToReturn: [WalletTransaction] = []
  var sendTransactionHashToReturn: String = "0x" + String(repeating: "0", count: 64)

  private(set) var sendTransactionCalls: [(chainId: Int, params: WalletTransactionParams)] = []
  private(set) var getERC20BalanceCalls: [(chainId: Int, tokenAddress: String, decimals: Int?)] = []
  private(set) var getTransactionsCalls: [(chainId: Int, limit: Int?, offset: Int?, order: WalletTransactionOrder?)] = []

  func address() async throws -> String { addressToReturn }

  func sendTransaction(chainId: Int, params: WalletTransactionParams) async throws -> String {
    sendTransactionCalls.append((chainId, params))
    return sendTransactionHashToReturn
  }

  func getNativeBalance(chainId: Int) async throws -> Double { nativeBalanceToReturn }

  func getERC20Balance(chainId: Int, tokenAddress: String, decimals: Int?) async throws -> Double {
    getERC20BalanceCalls.append((chainId, tokenAddress, decimals))
    return erc20BalanceToReturn
  }

  func getERC20Balances(chainId: Int) async throws -> [String: Double] { erc20BalancesToReturn }

  func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction] {
    getTransactionsCalls.append((chainId, limit, offset, order))
    return transactionsToReturn
  }
}

extension TestManagers {
  /// Returns a wallet-agnostic-initialized manager with a `StubWalletProvider` wired via
  /// `setWalletProvider`. The returned stub is mutable — tests configure return values on it.
  static func stubProviderManager(
    configs: [NetworkConfig] = TestFixtures.configs()
  ) async throws -> (RainSDKManager, StubWalletProvider) {
    let manager = try await TestManagers.walletAgnosticManager(configs: configs)
    let stub = StubWalletProvider()
    manager.setWalletProvider(stub)
    return (manager, stub)
  }
}
