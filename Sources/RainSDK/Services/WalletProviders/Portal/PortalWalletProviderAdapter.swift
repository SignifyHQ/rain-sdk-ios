import Foundation
import PortalSwift

/// Portal-based implementation of `RainWalletProvider`.
/// Used when the SDK is initialized with `initializePortal(...)`.
internal final class PortalWalletProviderAdapter: RainWalletProvider, RainTypedDataSignerProvider, RainTransactionFeeEstimatingProvider, @unchecked Sendable {
  private let portal: PortalRequestProtocol
  private let transactionBuilder: TransactionBuilderProtocol?

  internal init(
    portal: PortalRequestProtocol,
    transactionBuilder: TransactionBuilderProtocol? = nil
  ) {
    self.portal = portal
    self.transactionBuilder = transactionBuilder
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
    _ = try await portal.request(
      chainId: chainIdString,
      method: .eth_call,
      params: [ethParam, "latest"],
      options: nil
    )

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
  ) async throws -> Double {
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
    let gasPrice = try await fetchGasData(
      chainId: chainId,
      method: .eth_gasPrice,
      address: walletAddress
    ).weiToEth

    return estimateGas * gasPrice
  }

  /// Fetches native token balance (e.g. ETH) via eth_getBalance and parses the RPC response (PortalProviderRpcResponse → result?.asDouble?.weiToEth).
  public func getNativeBalance(
    chainId: Int
  ) async throws -> Double {
    let walletAddress = try await address()
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let response = try await portal.request(
      chainId: chainIdString,
      method: .eth_getBalance,
      params: [
        walletAddress,
        "latest"
      ],
      options: nil
    )
    
    guard let ethBalanceRpcResponse = response.result as? PortalProviderRpcResponse else {
      RainLogger.error("Rain SDK: Error fetching native balance for \(walletAddress). Unexpected RPC response")
      throw RainSDKError.internalLogicError(details: "Unexpected RPC response when fetching native balance")
    }
    
    guard let ethBalance = ethBalanceRpcResponse.result?.asDouble?.weiToEth else {
      RainLogger.error("Rain SDK: Error fetching native balance for \(walletAddress). Missing or invalid balance in response")
      throw RainSDKError.internalLogicError(details: "Unexpected eth_getBalance response")
    }
    
    return ethBalance
  }

  /// Fetches ERC-20 balance for a single token via direct RPC `eth_call` (balanceOf).
  /// Mirrors the Android implementation: ABI-encodes `balanceOf(address)`, calls `eth_call`, then parses the hex uint256 result.
  public func getERC20Balance(
    chainId: Int,
    tokenAddress: String,
    decimals: Int?
  ) async throws -> Double {
    guard let transactionBuilder else {
      throw RainSDKError.sdkNotInitialized
    }
    let walletAddress = try await address()
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let callData = try await transactionBuilder.encodeBalanceOfCall(walletAddress: walletAddress, chainId: chainId)
    let callParams: [String: Any] = [
      "to": tokenAddress,
      "data": callData
    ]

    do {
      let response = try await portal.request(
        chainId: chainIdString,
        method: .eth_call,
        params: [callParams, "latest"],
        options: nil
      )

      let hex = EthereumConverter.extractHexString(from: response)
      return EthereumConverter.parseHexToDouble(hex, decimals: decimals ?? Constants.ERC20.defaultDecimals)
    } catch {
      if error is RainSDKError { throw error }
      
      RainLogger.error("Rain SDK: Failed to get ERC20 balance via RPC for token=\(tokenAddress) chainId=\(chainId): \(error)")
      throw RainSDKError.providerError(underlying: error)
    }
  }

  /// Fetches the symbol for an ERC-20 token via direct RPC `eth_call` (symbol()).
  private func getTokenSymbol(
    chainId: Int,
    tokenAddress: String
  ) async throws -> String? {
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let callParams: [String: Any] = [
      "to": tokenAddress,
      "data": "0x95d89b41" // symbol() selector = keccak256("symbol()")[:4]
    ]

    do {
      let response = try await portal.request(
        chainId: chainIdString,
        method: .eth_call,
        params: [callParams, "latest"],
        options: nil
      )
      let hex = EthereumConverter.extractHexString(from: response)
      return EthereumConverter.parseHexToString(hex)
    } catch {
      if error is RainSDKError { throw error }
      RainLogger.error("Rain SDK: Failed to get token symbol via RPC for token=\(tokenAddress) chainId=\(chainId): \(error)")
      throw RainSDKError.providerError(underlying: error)
    }
  }

  /// Fetches the decimal places for an ERC-20 token via direct RPC `eth_call` (decimals()).
  /// Calls the `decimals()` selector (0x313ce567) on the token contract and parses the uint8 result.
  private func getTokenDecimals(
    chainId: Int,
    tokenAddress: String
  ) async throws -> Int {
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let callParams: [String: Any] = [
      "to": tokenAddress,
      "data": "0x313ce567" // decimals() selector = keccak256("decimals()")[:4]
    ]

    do {
      let response = try await portal.request(
        chainId: chainIdString,
        method: .eth_call,
        params: [callParams, "latest"],
        options: nil
      )
      let hex = EthereumConverter.extractHexString(from: response)
      return EthereumConverter.parseHexToInt(hex)
    } catch {
      if error is RainSDKError { throw error }
      RainLogger.error("Rain SDK: Failed to get token decimals via RPC for token=\(tokenAddress) chainId=\(chainId): \(error)")
      throw RainSDKError.providerError(underlying: error)
    }
  }

  /// Fetches ERC-20 token balances via Portal's getBalances and returns a contract-address-to-balance dictionary.
  public func getERC20Balances(
    chainId: Int
  ) async throws -> [String: Double] {
    let chainIdString = ChainIDFormat.EIP155.format(chainId: chainId)
    let tokenBalances = try await portal.getAssets(chainIdString).tokenBalances
    
    // Create portal balances dictionary with ERC20 token balances as initial data
    let portalBalances: [String: Double] = tokenBalances?.reduce(into: [:]) { partialResult, balance in
      if let address = balance.metadata?.tokenAddress,
         let amount = balance.balance?.asDouble {
        partialResult[address] = amount
      }
    } ?? [:]
    
    return portalBalances
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

    await withTaskGroup(of: (String, Int?, String?)?.self) { group in
      for address in addresses {
        group.addTask { [self] in
          async let decimals = try? self.getTokenDecimals(chainId: chainId, tokenAddress: address)
          async let symbol   = try? self.getTokenSymbol(chainId: chainId, tokenAddress: address)
          return (address, await decimals, await symbol)
        }
      }
      for await result in group {
        guard let (address, decimals, symbol) = result else { continue }
        if let decimals { decimalsMap[address] = decimals }
        if let symbol   { symbolsMap[address]  = symbol }
      }
    }

    // Apply enriched data back to transactions
    for i in transactions.indices {
      guard let address = transactions[i].rawContract?.address else { continue }

      if transactions[i].value == nil, let hex = transactions[i].rawContract?.value {
        let decimals = transactions[i].rawContract?.decimal.flatMap { Int($0) }
          ?? decimalsMap[address]
          ?? Constants.ERC20.defaultDecimals
        transactions[i].value = EthereumConverter.parseHexToDouble(hex, decimals: decimals)
      }

      if transactions[i].asset?.isEmpty ?? true, let symbol = symbolsMap[address] {
        transactions[i].asset = symbol
      }
    }
  }

  /// Fetches gas-related RPC result (e.g. eth_estimateGas, eth_gasPrice) via Portal; returns numeric value as Double.
  ///
  /// The underlying `PortalProviderResult.result` can come back in different shapes depending on
  /// the Portal SDK / transport. This helper supports:
  /// - `PortalProviderRpcResponse` whose `result` is a `String` that can be parsed as `Double`
  /// - a raw `String` that can be parsed as `Double`
  /// - a raw numeric type (`NSNumber` / `Double`)
  private func fetchGasData(
    chainId: Int,
    method: PortalRequestMethod,
    address: String,
    params: [Any] = []
  ) async throws -> Double {
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
       let doubleValue = stringResult.asDouble {
      return doubleValue
    }

    // 2) Fallback: raw string result
    if let stringResult = response.result as? String,
       let doubleValue = stringResult.asDouble {
      return doubleValue
    }

    // 3) Fallback: raw numeric result
    if let numberResult = response.result as? NSNumber {
      return numberResult.doubleValue
    }

    RainLogger.error("Rain SDK: Error fetching \(method) for \(address). Unexpected RPC response")
    throw RainSDKError.internalLogicError(
      details: "Unexpected RPC response when fetching \(method) for \(address)"
    )
  }
}
