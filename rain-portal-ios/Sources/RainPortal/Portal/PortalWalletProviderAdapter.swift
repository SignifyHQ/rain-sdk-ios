import Foundation
import PortalSwift
import RainCore
import Web3

/// Portal-based implementation of `RainWalletProvider`. Lives in the `RainPortal` module.
internal final class PortalWalletProviderAdapter: RainWalletProvider, RainTypedDataSignerProvider, RainTransactionFeeEstimatingProvider, @unchecked Sendable {
  private let portal: PortalRequestProtocol
  private let tokenStore: TokenMetadataStore

  internal init(
    portal: PortalRequestProtocol,
    tokenStore: TokenMetadataStore
  ) {
    self.portal = portal
    self.tokenStore = tokenStore
  }

  public func address(
  ) async throws -> String {
    let addresses = try await portal.addresses
    let eip155 = PortalNamespace.eip155
    
    guard let addr = addresses[eip155] ?? nil, !addr.isEmpty else {
      throw RainSDKError.walletUnavailable
    }
    
    return addr
  }

  public func sendTransaction(
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> String {
    let ethParam = ETHTransactionParam(
      from: params.from,
      to: params.to,
      value: params.value,
      data: params.data
    )
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)

    // Simulate the transaction first via eth_call to catch failures (e.g. insufficient funds)
    // before broadcasting — no balance fetch needed, the node validates it for free.
    do {
      _ = try await portal.request(
        chainId: chainIdString,
        method: .eth_call,
        params: [ethParam, "latest"],
        options: nil
      )
    } catch {
      if error is CancellationError { throw error }
      throw RainSDKError.transactionSimulationFailed(underlying: error)
    }

    let response = try await portal.request(
      chainId: chainIdString,
      method: .eth_sendTransaction,
      params: [ethParam],
      options: nil
    )

    guard let txHash = response.result as? String else {
      throw RainSDKError.internalLogicError(details: "eth_sendTransaction returned no transaction hash")
    }
    
    return txHash
  }

  func signTypedData(
    chainId: Int,
    walletAddress: String,
    typedData: String
  ) async throws -> String {
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)

    let response = try await portal.request(
      chainId: chainIdString,
      method: .eth_signTypedData_v4,
      params: [walletAddress, typedData],
      options: nil
    )

    guard let signature = response.result as? String else {
      throw RainSDKError.internalLogicError(details: "eth_signTypedData_v4 returned no signature")
    }

    return signature
  }

  func estimateTransactionFee(
    chainId: Int,
    walletAddress: String,
    params: WalletTransactionParams
  ) async throws -> Decimal {
    let ethParam = ETHTransactionParam(
      from: params.from,
      to: params.to,
      value: params.value,
      data: params.data
    )

    let estimateGas = try await fetchGasData(
      chainId: chainId,
      method: .eth_estimateGas,
      address: walletAddress,
      params: [ethParam]
    )
    let gasPriceWei = try await fetchGasData(
      chainId: chainId,
      method: .eth_gasPrice,
      address: walletAddress
    )

    // Exact wei math: multiply as BigUInt, divide to native units as Decimal.
    return EthereumConverter.baseUnitsToDecimal(
      estimateGas * gasPriceWei,
      decimals: Constants.ERC20.defaultDecimals
    )
  }

  public func getBalance(
    chainId: Int,
    token: Token
  ) async throws -> RainCore.Balance {
    switch token {
    case .native:
      return try await fetchNativeBalance(chainId: chainId)
    case .contract(let address):
      return try await fetchContractBalance(chainId: chainId, address: address)
    }
  }

  public func getBalances(
    chainId: Int
  ) async throws -> [RainCore.Balance] {
    let native = try await fetchNativeBalance(chainId: chainId)
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let tokenBalances = try await portal.getAssets(chainIdString).tokenBalances ?? []

    var output: [RainCore.Balance] = [native]
    for entry in tokenBalances {
      guard let address = entry.metadata?.tokenAddress, !address.isEmpty else { continue }
      let info = await tokenStore.tokenInfo(chainId: chainId, address: address)
      let raw = reconstructRawAmount(entry: entry, decimals: info.decimals)
      guard raw > 0 else { continue }
      output.append(
        RainCore.Balance(
          token: .contract(address: address),
          chainId: chainId,
          rawAmount: raw,
          decimals: info.decimals,
          symbol: info.symbol ?? entry.symbol,
          name: info.name ?? entry.name
        )
      )
    }
    return output
  }

  /// Fetches the native balance via `eth_getBalance`, preserving exact wei precision.
  private func fetchNativeBalance(chainId: Int) async throws -> RainCore.Balance {
    let walletAddress = try await address()
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let response = try await portal.request(
      chainId: chainIdString,
      method: .eth_getBalance,
      params: [walletAddress, "latest"],
      options: nil
    )
    let raw = try parseBalanceString(portalResultString(response))
    let native = await tokenStore.nativeCurrency(for: chainId)
    return RainCore.Balance(
      token: .native,
      chainId: chainId,
      rawAmount: raw,
      decimals: native.decimals,
      symbol: native.symbol,
      name: native.name
    )
  }

  /// Fetches a single ERC-20 balance via direct RPC `eth_call` (balanceOf), preserving exact precision.
  private func fetchContractBalance(chainId: Int, address: String) async throws -> RainCore.Balance {
    let walletAddress = try await self.address()
    let info = await tokenStore.tokenInfo(chainId: chainId, address: address)
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let callData = Multicall3.encodeBalanceOf(address: walletAddress)
    let callParams: [String: Any] = [
      "to": address,
      "data": callData
    ]

    do {
      let response = try await portal.request(
        chainId: chainIdString,
        method: .eth_call,
        params: [callParams, "latest"],
        options: nil
      )
      let raw = try EthereumConverter.parseHexToBigUIntStrict(response.hexString)
      return RainCore.Balance(
        token: .contract(address: address),
        chainId: chainId,
        rawAmount: raw,
        decimals: info.decimals,
        symbol: info.symbol,
        name: info.name
      )
    } catch {
      if error is RainSDKError { throw error }
      RainLogger.error("Rain SDK: Failed to get ERC20 balance via RPC for token=\(address) chainId=\(chainId): \(error)")
      throw RainSDKError.providerError(underlying: error)
    }
  }

  /// Extracts the string payload from a Portal RPC result, whether wrapped in a
  /// `PortalProviderRpcResponse` or returned as a raw `String`.
  private func portalResultString(_ response: PortalProviderResult) -> String? {
    if let rpcResponse = response.result as? PortalProviderRpcResponse {
      return rpcResponse.result
    }
    if let stringResult = response.result as? String {
      return stringResult
    }
    return nil
  }

  /// Parses a balance string that may be hex (`0x…`, production) or decimal (mocks / some
  /// transports) into an exact `BigUInt`. Malformed hex throws instead of collapsing to a
  /// silent zero balance.
  private func parseBalanceString(_ value: String?) throws -> BigUInt {
    guard let value, !value.isEmpty else { return 0 }
    if value.hasPrefix("0x") || value.hasPrefix("0X") {
      return try EthereumConverter.parseHexToBigUIntStrict(value)
    }
    return BigUInt(value) ?? 0
  }

  /// Reconstructs the exact base-unit amount for a Portal asset entry: prefer the raw
  /// integer string when present, else reconstruct from the formatted decimal balance.
  private func reconstructRawAmount(entry: TokenBalanceResponse, decimals: Int) -> BigUInt {
    if let rawBalance = entry.rawBalance, let raw = BigUInt(rawBalance) {
      return raw
    }
    return EthereumConverter.decimalStringToBigUInt(entry.balance, decimals: decimals)
  }

  /// Auto-enriches missing `value` and `asset` fields on returned transactions via on-chain
  /// `decimals()` / `symbol()` calls — Portal's transaction API returns raw contract data
  /// but not the human-readable values, so we backfill them here.
  public func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction] {
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let portalOrder = order?.toPortalOrder
    let fetchedTransactions = try await portal.getTransactions(
      chainIdString,
      limit: limit,
      offset: offset,
      order: portalOrder
    )

    var transactions = fetchedTransactions.map(WalletTransaction.init)
    await enrichTransactions(&transactions, chainId: chainId)
    return transactions
  }

  // MARK: - Transaction Enrichment

  /// Fills in missing `value` and `asset` on each transaction by calling `decimals()` and `symbol()`
  /// on the token contracts. Fetches each unique contract address once, in parallel.
  private func enrichTransactions(_ transactions: inout [WalletTransaction], chainId: Int) async {
    let addresses = Set(
      transactions.compactMap { tx -> String? in
        guard let address = tx.rawContract?.address, !address.isEmpty else { return nil }
        let needsDecimals = tx.value == nil && tx.rawContract?.value != nil && tx.rawContract?.decimal == nil
        let needsSymbol   = tx.asset?.isEmpty ?? true
        return (needsDecimals || needsSymbol) ? address : nil
      }
    )
    guard !addresses.isEmpty else { return }

    // Fetch decimals + symbol for each address in parallel
    var decimalsMap: [String: Int] = [:]
    var symbolsMap:  [String: String] = [:]

    await withTaskGroup(of: (String, TokenInfo).self) { group in
      for address in addresses {
        group.addTask { [tokenStore] in
          let info = await tokenStore.tokenInfo(chainId: chainId, address: address)
          return (address, info)
        }
      }
      for await (address, info) in group {
        decimalsMap[address] = info.decimals
        if let symbol = info.symbol { symbolsMap[address] = symbol }
      }
    }

    // Apply enriched data back to transactions
    for i in transactions.indices {
      guard let address = transactions[i].rawContract?.address else { continue }

      if transactions[i].value == nil, let hex = transactions[i].rawContract?.value {
        let decimals = transactions[i].rawContract?.decimal.flatMap { Int($0) }
          ?? decimalsMap[address]
          ?? Constants.ERC20.defaultDecimals
        transactions[i].value = EthereumConverter.parseHexToDecimal(hex, decimals: decimals)
      }

      if transactions[i].asset?.isEmpty ?? true, let symbol = symbolsMap[address] {
        transactions[i].asset = symbol
      }
    }
  }

  /// Fetches gas-related RPC result (e.g. eth_estimateGas, eth_gasPrice) via Portal; returns the
  /// exact wei-level value as `BigUInt`.
  ///
  /// The underlying `PortalProviderResult.result` can come back in different shapes depending on
  /// the Portal SDK / transport. This helper supports:
  /// - `PortalProviderRpcResponse` whose `result` is a hex (`0x…`) or decimal string
  /// - a raw hex or decimal `String`
  /// - a raw numeric type (`NSNumber`)
  private func fetchGasData(
    chainId: Int,
    method: PortalRequestMethod,
    address: String,
    params: [Any] = []
  ) async throws -> BigUInt {
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)

    let response = try await portal.request(
      chainId: chainIdString,
      method: method,
      params: params,
      options: nil
    )

    // 1) Preferred: PortalProviderRpcResponse wrapping a string result
    if let rpcResponse = response.result as? PortalProviderRpcResponse,
       let stringResult = rpcResponse.result,
       let value = Self.parseGasValue(stringResult) {
      return value
    }

    // 2) Fallback: raw string result
    if let stringResult = response.result as? String,
       let value = Self.parseGasValue(stringResult) {
      return value
    }

    // 3) Fallback: raw numeric result
    if let numberResult = response.result as? NSNumber,
       let value = BigUInt(numberResult.stringValue) {
      return value
    }

    RainLogger.error("Rain SDK: Error fetching \(method) for \(address). Unexpected RPC response")
    throw RainSDKError.internalLogicError(
      details: "Unexpected RPC response when fetching \(method) for \(address)"
    )
  }

  /// Parses a gas value string that may be hex (`0x…`, production) or decimal (mocks / some
  /// transports) into an exact `BigUInt`. Integral float renderings (`"21000.0"`) are accepted;
  /// fractional or otherwise malformed values return `nil`.
  private static func parseGasValue(_ value: String) -> BigUInt? {
    guard !value.isEmpty else { return nil }
    if value.hasPrefix("0x") || value.hasPrefix("0X") {
      return BigUInt(value.dropFirst(2), radix: 16)
    }
    if let integral = BigUInt(value) {
      return integral
    }
    // Some transports render integral gas values as floats. Parse exactly via Decimal (no Double
    // rounding) and accept only a whole, non-negative value; the strict full-match pattern keeps
    // genuinely malformed input (trailing junk, negatives) rejected.
    let pattern = "^[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?$"
    guard value.range(of: pattern, options: .regularExpression) != nil,
          let decimal = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) else {
      return nil
    }
    var source = decimal
    var rounded = Decimal()
    NSDecimalRound(&rounded, &source, 0, .down)
    guard rounded == decimal else { return nil }
    return BigUInt(NSDecimalNumber(decimal: rounded).stringValue, radix: 10)
  }
}
