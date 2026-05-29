import Foundation
import Web3
@testable import RainSDK

/// Provider-agnostic stub for manager-contract tests. Returns configured values and
/// records calls — use when a test only needs to prove the manager routes to the
/// provider and returns the provider's result, without invoking Portal- or Turnkey-specific behavior.
final class StubWalletProvider: RainWalletProvider, @unchecked Sendable {
  var addressToReturn: String = TestFixtures.walletAddress
  var balanceToReturn: Balance?
  var balancesToReturn: [Balance] = []
  var transactionsToReturn: [WalletTransaction] = []
  var sendTransactionHashToReturn: String = "0x" + String(repeating: "0", count: 64)

  /// Per-chain overrides for `getBalances`. When a chainId has an entry, it takes
  /// precedence over `balancesToReturn`.
  var balancesByChainId: [Int: [Balance]] = [:]
  /// Per-chain errors. When a chainId has an entry, both balance methods throw it.
  var errorsByChainId: [Int: Error] = [:]

  private(set) var sendTransactionCalls: [(chainId: Int, params: WalletTransactionParams)] = []
  private(set) var getBalanceCalls: [(chainId: Int, token: Token)] = []
  private(set) var getBalancesCalls: [Int] = []
  private(set) var getTransactionsCalls: [(chainId: Int, limit: Int?, offset: Int?, order: WalletTransactionOrder?)] = []

  func address() async throws -> String { addressToReturn }

  func sendTransaction(chainId: Int, params: WalletTransactionParams) async throws -> String {
    sendTransactionCalls.append((chainId, params))
    return sendTransactionHashToReturn
  }

  func getBalance(chainId: Int, token: Token) async throws -> Balance {
    getBalanceCalls.append((chainId, token))
    if let err = errorsByChainId[chainId] { throw err }
    return balanceToReturn ?? Balance(token: token, chainId: chainId, rawAmount: 0, decimals: 18)
  }

  func getBalances(chainId: Int) async throws -> [Balance] {
    getBalancesCalls.append(chainId)
    if let err = errorsByChainId[chainId] { throw err }
    return balancesByChainId[chainId] ?? balancesToReturn
  }

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
