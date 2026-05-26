import Foundation

/// EVM implementation of `ChainReader`.
///
/// **Primary path** — Multicall3 (`aggregate3`) for batched balance reads, so a wallet
/// holding N tokens on a chain costs one RPC round-trip regardless of N. Used when
/// `Multicall3.isCanonicallyDeployed(on:)` returns true for the target chain (static
/// list from https://www.multicall3.com/deployments).
///
/// **Fallback** — parallel `eth_call` (`balanceOf`) and `eth_getBalance`, used on
/// chains outside the static deployment list.
///
/// Per-token failures (multicall entry reverts, or fallback eth_call errors) propagate
/// as `RainSDKError` — callers see real errors rather than silent zeros.
internal final class EVMChainReader: ChainReader, @unchecked Sendable {
  private enum ReaderConstants {
    /// Decimals used for native balances. Every chain the SDK targets today uses 18.
    static let defaultNativeDecimals = 18
  }

  private let jsonRpcClient: JsonRpcClient
  private let networkConfigResolver: @Sendable (Int) -> NetworkConfig?

  internal init(
    jsonRpcClient: JsonRpcClient = JsonRpcClient(),
    networkConfigResolver: @escaping @Sendable (Int) -> NetworkConfig?
  ) {
    self.jsonRpcClient = jsonRpcClient
    self.networkConfigResolver = networkConfigResolver
  }

  /// Convenience init that builds the resolver from a list of network configs.
  internal convenience init(
    jsonRpcClient: JsonRpcClient = JsonRpcClient(),
    networkConfigs: [NetworkConfig]
  ) {
    let lookup = Dictionary(uniqueKeysWithValues: networkConfigs.map { ($0.chainId, $0) })
    self.init(jsonRpcClient: jsonRpcClient, networkConfigResolver: { lookup[$0] })
  }

  // MARK: - ChainReader

  func getNativeBalance(chainId: Int, walletAddress: String) async throws -> Double {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    try validate(ethereumAddress: walletAddress, label: "wallet address")
    let hex = try await jsonRpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_getBalance",
      params: [walletAddress, "latest"]
    )
    return EthereumConverter.parseHexToDouble(hex, decimals: ReaderConstants.defaultNativeDecimals)
  }

  func getERC20Balance(
    chainId: Int,
    tokenAddress: String,
    walletAddress: String,
    decimals: Int?
  ) async throws -> Double {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    try validate(ethereumAddress: walletAddress, label: "wallet address")
    try validate(ethereumAddress: tokenAddress, label: "token address")
    let callData = Multicall3.encodeBalanceOf(address: walletAddress)
    let callParams: [String: Any] = [
      "to": tokenAddress,
      "data": callData
    ]
    let hex = try await jsonRpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_call",
      params: [callParams, "latest"]
    )
    return EthereumConverter.parseHexToDouble(
      hex,
      decimals: decimals ?? Constants.ERC20.defaultDecimals
    )
  }

  func getBalances(
    chainId: Int,
    walletAddress: String,
    tokens: [TokenSpec]
  ) async throws -> [String: Double] {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    try validate(ethereumAddress: walletAddress, label: "wallet address")
    if Multicall3.isCanonicallyDeployed(on: chainId) {
      return try await fetchViaMulticall3(
        rpcUrl: rpcUrl,
        chainId: chainId,
        walletAddress: walletAddress,
        tokens: tokens
      )
    }
    return try await fetchViaParallelCalls(
      rpcUrl: rpcUrl,
      walletAddress: walletAddress,
      tokens: tokens
    )
  }

  // MARK: - Multicall3 path

  private func fetchViaMulticall3(
    rpcUrl: String,
    chainId: Int,
    walletAddress: String,
    tokens: [TokenSpec]
  ) async throws -> [String: Double] {
    // `allowFailure: true` so we get back per-call status. A revert on any entry is
    // surfaced as a `RainSDKError.internalLogicError` (see decode loop below) — we
    // don't silently zero failed entries; callers should see real errors.
    var calls: [Multicall3.Call3] = [
      Multicall3.Call3(
        target: Multicall3.canonicalAddress,
        allowFailure: true,
        callData: Multicall3.encodeGetEthBalance(address: walletAddress)
      )
    ]
    for token in tokens {
      calls.append(
        Multicall3.Call3(
          target: token.address,
          allowFailure: true,
          callData: Multicall3.encodeBalanceOf(address: walletAddress)
        )
      )
    }

    let aggregateCallData = Multicall3.encodeAggregate3(calls)
    let callParams: [String: Any] = [
      "to": Multicall3.canonicalAddress,
      "data": aggregateCallData
    ]
    let hex = try await jsonRpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_call",
      params: [callParams, "latest"]
    )
    let results = try Multicall3.decodeAggregate3Result(hex: hex)

    // Expect native + one entry per token.
    let expectedCount = tokens.count + 1
    guard results.count == expectedCount else {
      throw RainSDKError.internalLogicError(
        details: "Multicall3 returned \(results.count) results, expected \(expectedCount) on chain \(chainId)"
      )
    }

    var output: [String: Double] = [:]
    // Index 0 is the native balance.
    let nativeResult = results[0]
    guard nativeResult.success else {
      throw RainSDKError.internalLogicError(
        details: "Multicall3 native balance call reverted on chain \(chainId)"
      )
    }
    output[""] = EthereumConverter.parseHexToDouble(
      nativeResult.returnData,
      decimals: ReaderConstants.defaultNativeDecimals
    )
    for (i, token) in tokens.enumerated() {
      let result = results[i + 1]
      guard result.success else {
        throw RainSDKError.internalLogicError(
          details: "Multicall3 balanceOf reverted for token \(token.address) on chain \(chainId)"
        )
      }
      output[token.address] = EthereumConverter.parseHexToDouble(
        result.returnData,
        decimals: token.decimals
      )
    }
    return output
  }

  // MARK: - Parallel fallback path

  /// Fans out `eth_getBalance` (native) and per-token `eth_call balanceOf` requests
  /// concurrently via `withThrowingTaskGroup`. Any per-token failure throws — callers
  /// see real errors instead of silent zeros.
  private func fetchViaParallelCalls(
    rpcUrl: String,
    walletAddress: String,
    tokens: [TokenSpec]
  ) async throws -> [String: Double] {
    try await withThrowingTaskGroup(of: (String, Double).self) { group in
      group.addTask { [self] in
        let value = try await self.fetchNativeBalance(
          rpcUrl: rpcUrl,
          walletAddress: walletAddress
        )
        return ("", value)
      }
      for token in tokens {
        group.addTask { [self] in
          let value = try await self.fetchERC20Balance(
            rpcUrl: rpcUrl,
            tokenAddress: token.address,
            walletAddress: walletAddress,
            decimals: token.decimals
          )
          return (token.address, value)
        }
      }
      var output: [String: Double] = [:]
      for try await (key, value) in group {
        output[key] = value
      }
      return output
    }
  }

  private func fetchNativeBalance(rpcUrl: String, walletAddress: String) async throws -> Double {
    let hex = try await jsonRpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_getBalance",
      params: [walletAddress, "latest"]
    )
    return EthereumConverter.parseHexToDouble(hex, decimals: ReaderConstants.defaultNativeDecimals)
  }

  private func fetchERC20Balance(
    rpcUrl: String,
    tokenAddress: String,
    walletAddress: String,
    decimals: Int
  ) async throws -> Double {
    let callData = Multicall3.encodeBalanceOf(address: walletAddress)
    let callParams: [String: Any] = ["to": tokenAddress, "data": callData]
    let hex = try await jsonRpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_call",
      params: [callParams, "latest"]
    )
    return EthereumConverter.parseHexToDouble(hex, decimals: decimals)
  }

  // MARK: - Helpers

  /// Resolves and validates the RPC URL for `chainId`. Throws `invalidConfig` with the
  /// correct chain ID if the chain isn't configured or its URL is unparseable — without
  /// this, parse failures bubble up from `JsonRpcClient` with `chainId: 0`.
  private func resolveRpcUrl(chainId: Int) throws -> String {
    guard let config = networkConfigResolver(chainId) else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: "")
    }
    guard URL(string: config.rpcUrl) != nil else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: config.rpcUrl)
    }
    return config.rpcUrl
  }

  private func validate(ethereumAddress: String, label: String) throws {
    guard Multicall3.isValidAddress(ethereumAddress) else {
      throw RainSDKError.internalLogicError(
        details: "Invalid Ethereum \(label): \(ethereumAddress)"
      )
    }
  }
}
