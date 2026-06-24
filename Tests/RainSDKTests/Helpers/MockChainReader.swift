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

  struct SingleBalanceCall: Equatable {
    let chainId: Int
    let walletAddress: String
    let token: Token
  }

  struct MetadataCall: Equatable {
    let chainId: Int
    let tokenAddress: String
  }

  var stubbedBalances: [Balance] = []
  var stubbedSingleBalance: Balance? = nil
  var stubbedNative: Double = 0
  var stubbedErc20: Double = 0
  var stubbedDecimals: Int = 18
  var stubbedSymbol: String? = nil
  var stubbedName: String? = nil

  private(set) var balancesCalls: [BalancesCall] = []
  private(set) var getBalanceCalls: [SingleBalanceCall] = []
  private(set) var nativeCalls: [NativeCall] = []
  private(set) var erc20Calls: [ERC20Call] = []
  private(set) var decimalsCalls: [MetadataCall] = []
  private(set) var symbolCalls: [MetadataCall] = []
  private(set) var nameCalls: [MetadataCall] = []

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
    tokens: [TokenInfo]
  ) async throws -> [Balance] {
    balancesCalls.append(
      BalancesCall(
        chainId: chainId,
        walletAddress: walletAddress,
        tokenAddresses: tokens.map(\.address)
      )
    )
    return stubbedBalances
  }

  func getBalance(
    chainId: Int,
    walletAddress: String,
    token: Token,
    tokenInfo: TokenInfo?
  ) async throws -> Balance {
    getBalanceCalls.append(
      SingleBalanceCall(chainId: chainId, walletAddress: walletAddress, token: token)
    )
    if let stubbedSingleBalance {
      return stubbedSingleBalance
    }
    return Balance(
      token: token,
      chainId: chainId,
      rawAmount: 0,
      decimals: tokenInfo?.decimals ?? stubbedDecimals,
      symbol: tokenInfo?.symbol ?? stubbedSymbol,
      name: tokenInfo?.name
    )
  }

  func getDecimals(chainId: Int, tokenAddress: String) async throws -> Int {
    decimalsCalls.append(MetadataCall(chainId: chainId, tokenAddress: tokenAddress))
    return stubbedDecimals
  }

  func getSymbol(chainId: Int, tokenAddress: String) async throws -> String? {
    symbolCalls.append(MetadataCall(chainId: chainId, tokenAddress: tokenAddress))
    return stubbedSymbol
  }

  func getName(chainId: Int, tokenAddress: String) async throws -> String? {
    nameCalls.append(MetadataCall(chainId: chainId, tokenAddress: tokenAddress))
    return stubbedName
  }
}
