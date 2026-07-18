import Foundation
import PrivySDK
import RainCore
import Web3

/// Privy-backed `RainWalletProvider`.
///
/// Custody (signing, broadcasting) goes through Privy's EIP-1193 embedded wallet via
/// ``PrivyManager``; balance and fee reads run through ``PrivyRpcClient`` against Rain's
/// configured RPC, with metadata resolved by `tokenStore`.
///
/// Privy exposes no transaction-history endpoint, so ``getTransactions(chainId:limit:offset:order:)``
/// returns an empty list — on-chain history is expected to come from the Rain backend.
internal final class PrivyWalletProvider: RainWalletProvider, RainTypedDataSignerProvider, RainTransactionFeeEstimatingProvider, @unchecked Sendable {
  /// Upper bound on simultaneous per-token balance RPC calls in ``getBalances(chainId:)``. Without
  /// it a large token registry would fan out one connection per token at once.
  private static let maxConcurrentBalanceReads = 8

  private let manager: PrivyManager
  private let rpcEndpoints: [Int: String]
  private let tokenStore: TokenMetadataStore
  private let walletAddressOverride: String?
  private let rpcClient: PrivyRpcClient

  internal init(
    manager: PrivyManager,
    rpcEndpoints: [Int: String],
    tokenStore: TokenMetadataStore,
    walletAddressOverride: String? = nil,
    rpcClient: PrivyRpcClient = PrivyRpcClient()
  ) {
    self.manager = manager
    self.rpcEndpoints = rpcEndpoints
    self.tokenStore = tokenStore
    self.walletAddressOverride = walletAddressOverride
    self.rpcClient = rpcClient
  }

  // MARK: - Address

  func address() async throws -> String {
    try await manager.address(override: walletAddressOverride)
  }

  // Privy embedded wallets are Ethereum-only, so `getAddress(chainId:)` inherits the default
  // (returns `address()`).

  // MARK: - Send

  func sendTransaction(
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> String {
    let rpcUrl = try rpcUrl(for: chainId)

    // Simulate via eth_call before broadcasting to catch failures (revert / insufficient funds)
    // up front — the node validates it for free.
    do {
      _ = try await rpcClient.callForHexResult(
        rpcUrl: rpcUrl,
        method: "eth_call",
        params: [rpcTransactionObject(from: params), "latest"]
      )
    } catch {
      if error is CancellationError { throw error }
      throw RainSDKError.transactionSimulationFailed(underlying: error)
    }

    let transaction = EthereumRpcRequest.UnsignedEthTransaction(
      from: params.from,
      to: params.to,
      data: normalizedData(params.data),
      value: .hexadecimalNumber(params.value.isEmpty ? "0x0" : params.value),
      chainId: .int(chainId)
    )

    return try await manager.sendTransaction(
      walletAddress: params.from,
      rpcUrl: rpcUrl,
      chainId: chainId,
      transaction: transaction
    )
  }

  // MARK: - Sign

  func signTypedData(
    chainId: Int,
    walletAddress: String,
    typedData: String
  ) async throws -> String {
    try await manager.signTypedData(walletAddress: walletAddress, typedDataJson: typedData)
  }

  // MARK: - Fees

  func estimateTransactionFee(
    chainId: Int,
    walletAddress: String,
    params: WalletTransactionParams
  ) async throws -> Double {
    let rpcUrl = try rpcUrl(for: chainId)
    let gasLimitHex = try await rpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_estimateGas",
      params: [rpcTransactionObject(from: params)]
    )
    let gasPriceHex = try await rpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_gasPrice",
      params: []
    )
    let gasLimit = EthereumConverter.parseHexToDouble(gasLimitHex, decimals: 0)
    let gasPriceWei = EthereumConverter.parseHexToDouble(gasPriceHex, decimals: 0)
    return gasLimit * gasPriceWei.weiToEth
  }

  // MARK: - Balances

  func getBalance(
    chainId: Int,
    token: Token
  ) async throws -> Balance {
    let walletAddress = try await address()
    switch token {
    case .native:
      return try await fetchNativeBalance(chainId: chainId, walletAddress: walletAddress)
    case .contract(let contractAddress):
      return try await fetchContractBalance(
        chainId: chainId,
        walletAddress: walletAddress,
        address: contractAddress
      )
    }
  }

  func getBalances(
    chainId: Int
  ) async throws -> [Balance] {
    let walletAddress = try await address()

    // Native is essential: its failure propagates. Per-token reads are best-effort — a single
    // bad / failing contract must not drop the whole list, so each is wrapped and skipped on
    // failure. Concurrency is capped by a sliding window over the task group.
    let native = try await fetchNativeBalance(chainId: chainId, walletAddress: walletAddress)
    let tokens = await tokenStore.registeredTokens(for: chainId)

    var output: [Balance] = [native]
    guard !tokens.isEmpty else { return output }

    let contractBalances = await withTaskGroup(of: Balance?.self) { group in
      var nextIndex = 0
      let window = min(Self.maxConcurrentBalanceReads, tokens.count)
      while nextIndex < window {
        let address = tokens[nextIndex].address
        group.addTask { [self] in
          await tryFetchContractBalance(chainId: chainId, walletAddress: walletAddress, address: address)
        }
        nextIndex += 1
      }

      var collected: [Balance] = []
      for await result in group {
        if let balance = result, balance.rawAmount > 0 {
          collected.append(balance)
        }
        if nextIndex < tokens.count {
          let address = tokens[nextIndex].address
          group.addTask { [self] in
            await tryFetchContractBalance(chainId: chainId, walletAddress: walletAddress, address: address)
          }
          nextIndex += 1
        }
      }
      return collected
    }

    output.append(contentsOf: contractBalances)
    return output
  }

  /// Best-effort single contract balance: logs and returns `nil` on failure so one token never
  /// cancels the batch.
  private func tryFetchContractBalance(
    chainId: Int,
    walletAddress: String,
    address: String
  ) async -> Balance? {
    do {
      return try await fetchContractBalance(chainId: chainId, walletAddress: walletAddress, address: address)
    } catch {
      RainLogger.warning("Rain SDK: Privy balance read failed for token=\(address) chainId=\(chainId); skipping: \(error)")
      return nil
    }
  }

  private func fetchNativeBalance(chainId: Int, walletAddress: String) async throws -> Balance {
    let rpcUrl = try rpcUrl(for: chainId)
    let hex = try await rpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_getBalance",
      params: [walletAddress, "latest"]
    )
    let native = await tokenStore.nativeCurrency(for: chainId)
    return Balance(
      token: .native,
      chainId: chainId,
      rawAmount: EthereumConverter.parseHexToBigUInt(hex),
      decimals: native.decimals,
      symbol: native.symbol,
      name: native.name
    )
  }

  private func fetchContractBalance(
    chainId: Int,
    walletAddress: String,
    address: String
  ) async throws -> Balance {
    let rpcUrl = try rpcUrl(for: chainId)
    let info = await tokenStore.tokenInfo(chainId: chainId, address: address)
    let callData = Multicall3.encodeBalanceOf(address: walletAddress)
    let callObject: [String: Any] = ["to": address, "data": callData]
    let hex = try await rpcClient.callForHexResult(
      rpcUrl: rpcUrl,
      method: "eth_call",
      params: [callObject, "latest"]
    )
    return Balance(
      token: .contract(address: address),
      chainId: chainId,
      rawAmount: EthereumConverter.parseHexToBigUInt(hex),
      decimals: info.decimals,
      symbol: info.symbol,
      name: info.name
    )
  }

  // MARK: - Transactions

  /// Privy exposes no history endpoint; on-chain history comes from the Rain backend.
  func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction] {
    []
  }

  // MARK: - Helpers

  private func rpcUrl(for chainId: Int) throws -> String {
    guard let rpcUrl = rpcEndpoints[chainId], !rpcUrl.isEmpty else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: "")
    }
    return rpcUrl
  }

  /// Builds an `eth_call` / `eth_estimateGas` transaction object, omitting empty `data`.
  private func rpcTransactionObject(from params: WalletTransactionParams) -> [String: Any] {
    var transaction: [String: Any] = [
      "from": params.from,
      "to": params.to,
      "value": params.value.isEmpty ? "0x0" : params.value
    ]
    if let data = normalizedData(params.data) {
      transaction["data"] = data
    }
    return transaction
  }

  /// Normalizes calldata for Privy: `nil` for an empty / `"0x"` payload, else the hex string.
  private func normalizedData(_ data: String) -> String? {
    (data.isEmpty || data == "0x") ? nil : data
  }
}
