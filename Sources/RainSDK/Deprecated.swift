//
//  Deprecated.swift
//  RainSDK
//
//  Source-compat shims for the 1.0.0 public API. Slated for removal in the next major version.
//

import Foundation
import PortalSwift

public extension RainSDK {
  /// Deprecated alias for ``sendToken(chainId:contractAddress:to:amount:decimals:)``.
  @available(*, deprecated, message: "Renamed to sendToken (now also routes Solana SPL). It returns RainTokenTransferResult; read .transactionHash for the hash.")
  func sendERC20Token(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Double,
    decimals: Int
  ) async throws -> String {
    try await sendToken(
      chainId: chainId,
      contractAddress: contractAddress,
      to: to,
      amount: amount,
      decimals: Int?(decimals)
    ).transactionHash
  }

  /// Deprecated. `decimals` is now optional; the SDK resolves it from its registry or an
  /// on-chain `decimals()` read. Call `sendToken(chainId:contractAddress:to:amount:)` and
  /// omit `decimals`. Retained as a source-compat shim for callers compiled against the
  /// pre-resolution signature (`decimals: Int`).
  @available(*, deprecated, message: "decimals is now optional; the SDK resolves it. Call sendToken(chainId:contractAddress:to:amount:) and omit decimals.")
  func sendToken(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Double,
    decimals: Int
  ) async throws -> RainTokenTransferResult {
    try await sendToken(
      chainId: chainId,
      contractAddress: contractAddress,
      to: to,
      amount: amount,
      decimals: Int?(decimals)
    )
  }

  /// Deprecated alias for ``sendNative(chainId:to:amount:)``.
  @available(*, deprecated, message: "Renamed to sendNative. It returns RainTokenTransferResult; read .transactionHash for the hash.")
  func sendNativeToken(chainId: Int, to: String, amount: Double) async throws -> String {
    try await sendNative(chainId: chainId, to: to, amount: amount).transactionHash
  }

  /// Deprecated alias for ``buildTransactionParameters(walletAddress:contractAddress:transactionData:)``.
  @available(*, deprecated, message: "Renamed to buildTransactionParameters, which returns Rain-owned RainTransactionParameters. This shim adapts to Portal's ETHTransactionParam.")
  func composeTransactionParameters(walletAddress: String, contractAddress: String, transactionData: String) -> ETHTransactionParam {
    let p = buildTransactionParameters(walletAddress: walletAddress, contractAddress: contractAddress, transactionData: transactionData)
    return ETHTransactionParam(from: p.from, to: p.to, value: p.value, data: p.data)
  }

  /// Deprecated. Use ``getBalance(chainId:token:)`` with `.native` and read `.decimalAmount`.
  @available(*, deprecated, message: "Use getBalance(chainId:, token: .native) and read .decimalAmount for exact precision. This shim collapses to a lossy Double.")
  func getNativeBalance(chainId: Int) async throws -> Double {
    let b = try await getBalance(chainId: chainId, token: .native)
    return NSDecimalNumber(decimal: b.decimalAmount).doubleValue
  }

  /// Deprecated. Use ``getBalance(chainId:token:)`` with `.contract`. `decimals` is ignored.
  @available(*, deprecated, message: "Use getBalance(chainId:, token: .contract(address:)) and read .decimalAmount. decimals is ignored; the SDK resolves it.")
  func getERC20Balance(chainId: Int, tokenAddress: String, decimals: Int? = nil) async throws -> Double {
    let b = try await getBalance(chainId: chainId, token: .contract(address: tokenAddress))
    return NSDecimalNumber(decimal: b.decimalAmount).doubleValue
  }

  /// Deprecated. Use ``getTokenBalances(chainId:)``. Drops native; contracts keyed by verbatim address.
  @available(*, deprecated, message: "Use getTokenBalances(chainId:) -> [Balance]. This shim drops native and collapses to a lossy Double map keyed by contract address.")
  func getERC20Balances(chainId: Int) async throws -> [String: Double] {
    var out: [String: Double] = [:]
    for b in try await getTokenBalances(chainId: chainId) {
      if case .contract(let address) = b.token {
        out[address] = NSDecimalNumber(decimal: b.decimalAmount).doubleValue
      }
    }
    return out
  }

  /// Deprecated. Use ``getTokenBalances(chainId:)``. Native under "", contracts by verbatim address.
  @available(*, deprecated, message: "Use getTokenBalances(chainId:) -> [Balance]. This shim collapses to a lossy Double map keyed by contract address, native under the empty-string key.")
  func getBalances(chainId: Int) async throws -> [String: Double] {
    var out: [String: Double] = [:]
    for b in try await getTokenBalances(chainId: chainId) {
      switch b.token {
      case .native:
        out[""] = NSDecimalNumber(decimal: b.decimalAmount).doubleValue
      case .contract(let address):
        out[address] = NSDecimalNumber(decimal: b.decimalAmount).doubleValue
      }
    }
    return out
  }
}
