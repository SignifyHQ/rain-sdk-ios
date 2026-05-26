import Foundation
@testable import RainSDK

/// Test double for `ChainReader`. Records every call and returns canned values.
/// Used to assert that the Turnkey adapter delegates to the chain reader for
/// non-Turnkey chains while still using Turnkey's API for the allowlisted ones.
final class MockChainReader: ChainReader, @unchecked Sendable {
  struct BalancesCall: Equatable {
    let chainId: Int
    let walletAddress: String
    let tokenAddresses: [String]
  }

  struct ERC20Call: Equatable {
    let chainId: Int
    let tokenAddress: String
    let walletAddress: String
    let decimals: Int?
  }

  struct NativeCall: Equatable {
    let chainId: Int
    let walletAddress: String
  }

  var stubbedBalances: [String: Double] = [:]
  var stubbedNative: Double = 0
  var stubbedErc20: Double = 0

  private(set) var balancesCalls: [BalancesCall] = []
  private(set) var nativeCalls: [NativeCall] = []
  private(set) var erc20Calls: [ERC20Call] = []

  func getNativeBalance(chainId: Int, walletAddress: String) async throws -> Double {
    nativeCalls.append(NativeCall(chainId: chainId, walletAddress: walletAddress))
    return stubbedNative
  }

  func getERC20Balance(
    chainId: Int,
    tokenAddress: String,
    walletAddress: String,
    decimals: Int?
  ) async throws -> Double {
    erc20Calls.append(
      ERC20Call(
        chainId: chainId,
        tokenAddress: tokenAddress,
        walletAddress: walletAddress,
        decimals: decimals
      )
    )
    return stubbedErc20
  }

  func getBalances(
    chainId: Int,
    walletAddress: String,
    tokens: [TokenSpec]
  ) async throws -> [String: Double] {
    balancesCalls.append(
      BalancesCall(
        chainId: chainId,
        walletAddress: walletAddress,
        tokenAddresses: tokens.map(\.address)
      )
    )
    return stubbedBalances
  }
}
