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
/// Native balance failures are fatal — they indicate a chain-wide problem (bad RPC, wrong
/// chain ID). Per-token failures (a single `balanceOf` reverts) are logged via `RainLogger`
/// and the token is omitted from the result, so one bad `TokenRegistry` entry doesn't
/// break balance reads for the whole chain.
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
    tokens: [TokenInfo]
  ) async throws -> [Balance] {
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
      chainId: chainId,
      walletAddress: walletAddress,
      tokens: tokens
    )
  }

  func getBalance(
    chainId: Int,
    walletAddress: String,
    token: Token,
    tokenInfo: TokenInfo?
  ) async throws -> Balance {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    try validate(ethereumAddress: walletAddress, label: "wallet address")

    switch token {
    case .native:
      let hex = try await jsonRpcClient.callForHexResult(
        rpcUrl: rpcUrl,
        method: "eth_getBalance",
        params: [walletAddress, "latest"]
      )
      return nativeBalance(chainId: chainId, hex: hex)
    case .contract(let address):
      try validate(ethereumAddress: address, label: "token address")
      let callData = Multicall3.encodeBalanceOf(address: walletAddress)
      let hex = try await ethCall(rpcUrl: rpcUrl, to: address, data: callData)
      let info = tokenInfo ?? TokenInfo(
        chainId: chainId,
        address: address,
        symbol: nil,
        decimals: Constants.ERC20.defaultDecimals
      )
      return tokenBalance(chainId: chainId, token: info, hex: hex)
    }
  }

  func getDecimals(chainId: Int, tokenAddress: String) async throws -> Int {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    try validate(ethereumAddress: tokenAddress, label: "token address")
    let hex = try await ethCall(
      rpcUrl: rpcUrl,
      to: tokenAddress,
      data: "0x" + ERC20Selectors.decimals
    )
    return EthereumConverter.parseHexToInt(hex)
  }

  func getSymbol(chainId: Int, tokenAddress: String) async throws -> String? {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    try validate(ethereumAddress: tokenAddress, label: "token address")
    let hex = try await ethCall(
      rpcUrl: rpcUrl,
      to: tokenAddress,
      data: "0x" + ERC20Selectors.symbol
    )
    return EthereumConverter.parseHexToString(hex)
  }

  /// Issues a raw `eth_call` and returns the hex result. For read functions with
  /// pre-encoded `data` (no-arg selectors like `decimals()` / `symbol()`).
  private func ethCall(rpcUrl: String, to: String, data: String) async throws -> String {
    let callParams: [String: Any] = ["to": to, "data": data]
    return try await jsonRpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_call",
      params: [callParams, "latest"]
    )
  }

  // MARK: - Multicall3 path

  private func fetchViaMulticall3(
    rpcUrl: String,
    chainId: Int,
    walletAddress: String,
    tokens: [TokenInfo]
  ) async throws -> [Balance] {
    // `allowFailure: true` so we get back per-call status. Native failure is fatal;
    // per-token failures are logged and omitted from the result (see decode loop below).
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

    // Index 0 is the native balance.
    let nativeResult = results[0]
    guard nativeResult.success else {
      throw RainSDKError.internalLogicError(
        details: "Multicall3 native balance call reverted on chain \(chainId)"
      )
    }
    var output: [Balance] = [nativeBalance(chainId: chainId, hex: nativeResult.returnData)]
    for (i, token) in tokens.enumerated() {
      let result = results[i + 1]
      guard result.success else {
        RainLogger.warning(
          "Rain SDK: balanceOf reverted for token \(token.symbol ?? token.address) (\(token.address)) on chain \(chainId) — omitting from result"
        )
        continue
      }
      output.append(tokenBalance(chainId: chainId, token: token, hex: result.returnData))
    }
    return output
  }

  // MARK: - Parallel fallback path

  /// Fans out `eth_getBalance` (native) and per-token `eth_call balanceOf` requests
  /// concurrently via `withTaskGroup`. Native failure is fatal; per-token failures
  /// are logged and the token is omitted from the result.
  private func fetchViaParallelCalls(
    rpcUrl: String,
    chainId: Int,
    walletAddress: String,
    tokens: [TokenInfo]
  ) async throws -> [Balance] {
    // Native first, on its own — its failure is fatal and shouldn't be swallowed by a
    // group that's also tolerating per-token errors.
    let nativeHex = try await fetchNativeBalanceHex(
      rpcUrl: rpcUrl,
      walletAddress: walletAddress
    )
    let native = nativeBalance(chainId: chainId, hex: nativeHex)

    // `balanceOf(walletAddress)` calldata is identical across every token — encode once.
    let balanceOfCallData = Multicall3.encodeBalanceOf(address: walletAddress)

    return await withTaskGroup(of: Balance?.self) { group in
      for token in tokens {
        group.addTask { [self] in
          do {
            let hex = try await self.ethCall(
              rpcUrl: rpcUrl,
              to: token.address,
              data: balanceOfCallData
            )
            return self.tokenBalance(chainId: chainId, token: token, hex: hex)
          } catch {
            RainLogger.warning(
              "Rain SDK: balanceOf failed for token \(token.symbol ?? token.address) (\(token.address)): \(error) — omitting from result"
            )
            return nil
          }
        }
      }
      var output: [Balance] = [native]
      for await balance in group {
        if let balance { output.append(balance) }
      }
      return output
    }
  }

  private func fetchNativeBalanceHex(rpcUrl: String, walletAddress: String) async throws -> String {
    try await jsonRpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_getBalance",
      params: [walletAddress, "latest"]
    )
  }

  // MARK: - Balance builders

  /// Builds a native-currency `Balance` from a raw hex wei value, pulling symbol / name /
  /// decimals from the static native-currency table.
  private func nativeBalance(chainId: Int, hex: String) -> Balance {
    let native = TokenRegistry.nativeCurrency(for: chainId)
    return Balance(
      token: .native,
      chainId: chainId,
      rawAmount: EthereumConverter.parseHexToBigUInt(hex),
      decimals: native.decimals,
      symbol: native.symbol,
      name: native.name
    )
  }

  /// Builds a contract-token `Balance` from a raw hex base-unit value and the token's metadata.
  private func tokenBalance(chainId: Int, token: TokenInfo, hex: String) -> Balance {
    Balance(
      token: .contract(address: token.address),
      chainId: chainId,
      rawAmount: EthereumConverter.parseHexToBigUInt(hex),
      decimals: token.decimals,
      symbol: token.symbol,
      name: token.name
    )
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
    guard ethereumAddress.isValidEthereumAddress else {
      throw RainSDKError.internalLogicError(
        details: "Invalid Ethereum \(label): \(ethereumAddress)"
      )
    }
  }
}
