import Foundation
import TurnkeyHttp
import TurnkeySwift
import TurnkeyTypes
import Web3

/// Turnkey-based implementation of `RainWalletProvider`.
/// Used when the SDK is initialized with `initializeTurnkey(...)`.
internal final class TurnkeyWalletProviderAdapter: RainWalletProvider, RainTypedDataSignerProvider, RainTransactionFeeEstimatingProvider, @unchecked Sendable {
  private enum AdapterConstants {
    static let defaultNativeDecimals = 18
    static let defaultPollingAttempts = 30
    static let pollingIntervalNanoseconds: UInt64 = 1_000_000_000
  }

  private struct ActivityDraft: Sendable {
    let id: String
    let timestamp: TimeInterval
    let from: String
    let to: String
    let value: String?
    let data: String?
    let chainId: Int
    let sendTransactionStatusId: String?
  }

  private let turnkey: TurnkeyContextProtocol
  private let transactionBuilder: TransactionBuilderProtocol?
  private let networkConfigsByChainId: [Int: NetworkConfig]
  private let walletAddressOverride: String?

  internal init(
    turnkey: TurnkeyContextProtocol,
    transactionBuilder: TransactionBuilderProtocol? = nil,
    networkConfigs: [NetworkConfig],
    walletAddress: String? = nil
  ) {
    self.turnkey = turnkey
    self.transactionBuilder = transactionBuilder
    self.networkConfigsByChainId = Dictionary(uniqueKeysWithValues: networkConfigs.map { ($0.chainId, $0) })
    self.walletAddressOverride = walletAddress
  }

  public func address() async throws -> String {
    if let walletAddressOverride, !walletAddressOverride.isEmpty {
      return walletAddressOverride
    }

    if let walletAddress = resolveEthereumWalletAddress(from: turnkey.wallets) {
      return walletAddress
    }

    try await turnkey.refreshWallets()

    if let walletAddress = resolveEthereumWalletAddress(from: turnkey.wallets) {
      return walletAddress
    }

    throw RainSDKError.walletUnavailable
  }

  public func sendTransaction(
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> String {
    let (session, client) = try resolveSessionAndClient()
    let sendInput = try await buildTurnkeySendTransactionBody(
      session: session,
      chainId: chainId,
      params: params
    )
    let response = try await client.ethSendTransaction(sendInput)

    return try await pollForTransactionHash(
      client: client,
      organizationId: session.organizationId,
      sendTransactionStatusId: response.sendTransactionStatusId
    )
  }

  public func getNativeBalance(
    chainId: Int
  ) async throws -> Double {
    let walletAddress = try await address()
    let balances = try await fetchBalances(
      chainId: chainId,
      walletAddress: walletAddress
    )

    let caip2 = Constants.ChainIDFormat.EIP155.format(chainId: chainId)
    let nativeBalance = balances.first(where: { isNativeAsset($0, caip2: caip2) })

    return decimalStringToDouble(
      balance: nativeBalance?.balance,
      decimals: nativeBalance?.decimals ?? Self.AdapterConstants.defaultNativeDecimals
    )
  }

  public func getERC20Balance(
    chainId: Int,
    tokenAddress: String,
    decimals: Int?
  ) async throws -> Double {
    guard let transactionBuilder else {
      throw RainSDKError.sdkNotInitialized
    }

    let walletAddress = try await address()
    let callData = try await transactionBuilder.encodeBalanceOfCall(
      walletAddress: walletAddress,
      chainId: chainId
    )
    let callParams: [String: Any] = [
      "to": tokenAddress,
      "data": callData
    ]

    let response = try await rpcRequest(
      chainId: chainId,
      method: "eth_call",
      params: [callParams, "latest"]
    )
    let hex = try extractHexResult(from: response, method: "eth_call")

    return EthereumConverter.parseHexToDouble(
      hex,
      decimals: decimals ?? Constants.ERC20.defaultDecimals
    )
  }

  public func getERC20Balances(
    chainId: Int
  ) async throws -> [String: Double] {
    let walletAddress = try await address()
    let balances = try await fetchBalances(
      chainId: chainId,
      walletAddress: walletAddress
    )

    let caip2 = Constants.ChainIDFormat.EIP155.format(chainId: chainId)

    return balances.reduce(into: [:]) { partialResult, balance in
      guard let caip19 = balance.caip19,
            let tokenAddress = tokenAddress(from: caip19, caip2: caip2)
      else {
        return
      }

      partialResult[tokenAddress] = decimalStringToDouble(
        balance: balance.balance,
        decimals: balance.decimals ?? Constants.ERC20.defaultDecimals
      )
    }
  }

  public func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction] {
    let (session, client) = try resolveSessionAndClient()
    let requestedLimit = min(max((limit ?? 10) + (offset ?? 0), 1), 100)
    let activitiesResponse = try await client.getActivities(
      TGetActivitiesBody(
        organizationId: session.organizationId,
        filterByType: [.activity_type_eth_send_transaction],
        paginationOptions: v1Pagination(limit: String(requestedLimit))
      )
    )

    let matchingDrafts = activitiesResponse.activities.compactMap { activity in
      draftTransaction(from: activity, expectedChainId: chainId)
    }

    let sortedDrafts = matchingDrafts.sorted { lhs, rhs in
      switch order ?? .DESC {
      case .ASC:
        return lhs.timestamp < rhs.timestamp
      case .DESC:
        return lhs.timestamp > rhs.timestamp
      }
    }

    let slicedDrafts = Array(
      sortedDrafts
        .dropFirst(offset ?? 0)
        .prefix(limit ?? sortedDrafts.count)
    )

    var transactions: [WalletTransaction] = []
    transactions.reserveCapacity(slicedDrafts.count)

    for draft in slicedDrafts {
      let txHash = try? await resolveTransactionHash(
        client: client,
        organizationId: session.organizationId,
        sendTransactionStatusId: draft.sendTransactionStatusId
      )

      transactions.append(
        WalletTransaction(
          blockNum: "",
          uniqueId: draft.id,
          hash: txHash ?? draft.id,
          from: draft.from,
          to: draft.to,
          value: decimalStringToDouble(
            balance: draft.value,
            decimals: Self.AdapterConstants.defaultNativeDecimals
          ),
          erc721TokenId: nil,
          erc1155Metadata: nil,
          tokenId: nil,
          asset: nil,
          category: "external",
          rawContract: draft.data.flatMap { data in
            guard data != "0x" && !data.isEmpty else { return nil }
            return WalletTransaction.RawContract(
              value: nil,
              address: draft.to,
              decimal: nil
            )
          },
          metadata: WalletTransaction.Metadata(
            blockTimestamp: Self.iso8601String(from: draft.timestamp)
          ),
          chainId: draft.chainId
        )
      )
    }

    return transactions
  }

  func signTypedData(
    chainId: Int,
    walletAddress: String,
    typedData: String
  ) async throws -> String {
    let signature = try await turnkey.signRawPayload(
      signWith: walletAddress,
      payload: typedData,
      encoding: .payload_encoding_eip712,
      hashFunction: .hash_function_no_op
    )

    return Self.ethereumSignatureHex(from: signature)
  }

  func estimateTransactionFee(
    chainId: Int,
    walletAddress: String,
    params: WalletTransactionParams
  ) async throws -> Double {
    let estimateResponse = try await rpcRequest(
      chainId: chainId,
      method: "eth_estimateGas",
      params: [rpcTransactionObject(from: params)]
    )
    let gasPriceResponse = try await rpcRequest(
      chainId: chainId,
      method: "eth_gasPrice",
      params: []
    )

    let gasLimit = EthereumConverter.parseHexToDouble(
      try extractHexResult(from: estimateResponse, method: "eth_estimateGas"),
      decimals: 0
    )
    let gasPriceWei = EthereumConverter.parseHexToDouble(
      try extractHexResult(from: gasPriceResponse, method: "eth_gasPrice"),
      decimals: 0
    )

    return gasLimit * gasPriceWei.weiToEth
  }

  private func resolveSessionAndClient() throws -> (Session, any TurnkeyClientProtocol) {
    guard let session = turnkey.session else {
      throw TurnkeySwiftError.invalidSession
    }

    guard let client = turnkey.turnkeyClient else {
      throw TurnkeySwiftError.invalidSession
    }

    return (session, client)
  }

  private func fetchBalances(
    chainId: Int,
    walletAddress: String
  ) async throws -> [v1AssetBalance] {
    let (session, client) = try resolveSessionAndClient()
    let response = try await client.getWalletAddressBalances(
      TGetWalletAddressBalancesBody(
        organizationId: session.organizationId,
        address: walletAddress,
        caip2: Constants.ChainIDFormat.EIP155.format(chainId: chainId)
      )
    )

    return response.balances ?? []
  }

  private func buildTurnkeySendTransactionBody(
    session: Session,
    chainId: Int,
    params: WalletTransactionParams
  ) async throws -> TEthSendTransactionBody {
    let nonceResponse = try await rpcRequest(
      chainId: chainId,
      method: "eth_getTransactionCount",
      params: [params.from, "pending"]
    )
    let estimateGasResponse = try await rpcRequest(
      chainId: chainId,
      method: "eth_estimateGas",
      params: [rpcTransactionObject(from: params)]
    )
    let gasPriceResponse = try await rpcRequest(
      chainId: chainId,
      method: "eth_gasPrice",
      params: []
    )

    let nonce = decimalString(fromHex: try extractHexResult(from: nonceResponse, method: "eth_getTransactionCount"))
    let estimatedGas = BigUInt(
      decimalString(
        fromHex: try extractHexResult(from: estimateGasResponse, method: "eth_estimateGas")
      )
    ) ?? BigUInt(21_000)
    let bufferedGasLimit = estimatedGas + (estimatedGas / 5)
    let gasLimit = (bufferedGasLimit == 0 ? estimatedGas : bufferedGasLimit).description
    let gasPrice = decimalString(fromHex: try extractHexResult(from: gasPriceResponse, method: "eth_gasPrice"))

    return TEthSendTransactionBody(
      organizationId: session.organizationId,
      caip2: Constants.ChainIDFormat.EIP155.format(chainId: chainId),
      data: normalizedData(params.data),
      from: params.from,
      gasLimit: gasLimit,
      maxFeePerGas: gasPrice,
      maxPriorityFeePerGas: gasPrice,
      nonce: nonce,
      sponsor: false,
      to: params.to,
      value: decimalString(fromHex: params.value)
    )
  }

  private func resolveEthereumWalletAddress(from wallets: [Wallet]) -> String? {
    wallets
      .flatMap(\.accounts)
      .first(where: { $0.addressFormat == .address_format_ethereum })?
      .address
  }

  private func draftTransaction(
    from activity: v1Activity,
    expectedChainId: Int
  ) -> ActivityDraft? {
    guard let intent = activity.intent.ethSendTransactionIntent else {
      return nil
    }

    let chainId = chainId(from: intent.caip2)
    guard chainId == expectedChainId else {
      return nil
    }

    let seconds = Double(activity.createdAt.seconds) ?? 0
    let nanos = Double(activity.createdAt.nanos) ?? 0

    return ActivityDraft(
      id: activity.id,
      timestamp: seconds + nanos / 1_000_000_000,
      from: intent.from,
      to: intent.to,
      value: intent.value,
      data: intent.data,
      chainId: chainId,
      sendTransactionStatusId: activity.result.ethSendTransactionResult?.sendTransactionStatusId
    )
  }

  private func resolveTransactionHash(
    client: any TurnkeyClientProtocol,
    organizationId: String,
    sendTransactionStatusId: String?
  ) async throws -> String? {
    guard let sendTransactionStatusId else {
      return nil
    }

    let status = try await client.getSendTransactionStatus(
      TGetSendTransactionStatusBody(
        organizationId: organizationId,
        sendTransactionStatusId: sendTransactionStatusId
      )
    )
    return status.eth?.txHash
  }

  private func pollForTransactionHash(
    client: any TurnkeyClientProtocol,
    organizationId: String,
    sendTransactionStatusId: String
  ) async throws -> String {
    for attempt in 0..<Self.AdapterConstants.defaultPollingAttempts {
      let status = try await client.getSendTransactionStatus(
        TGetSendTransactionStatusBody(
          organizationId: organizationId,
          sendTransactionStatusId: sendTransactionStatusId
        )
      )

      if let txHash = status.eth?.txHash, !txHash.isEmpty {
        return txHash
      }

      let normalizedStatus = status.txStatus.uppercased()
      if normalizedStatus.contains("FAILED") || normalizedStatus.contains("REJECTED")
        || status.txError != nil || status.error?.message != nil
      {
        let message = status.txError
          ?? status.error?.message
          ?? "Turnkey transaction submission failed"
        throw RainSDKError.providerError(
          underlying: NSError(
            domain: "TurnkeyTransaction",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: message]
          )
        )
      }

      if attempt + 1 < Self.AdapterConstants.defaultPollingAttempts {
        try await Task.sleep(nanoseconds: Self.AdapterConstants.pollingIntervalNanoseconds)
      }
    }

    throw RainSDKError.internalLogicError(
      details: "Turnkey transaction status polling timed out"
    )
  }

  private func isNativeAsset(_ balance: v1AssetBalance, caip2: String) -> Bool {
    guard let caip19 = balance.caip19 else {
      return false
    }

    return caip19.hasPrefix("\(caip2)/slip44:")
  }

  private func tokenAddress(from caip19: String, caip2: String) -> String? {
    guard caip19.hasPrefix("\(caip2)/erc20:") else {
      return nil
    }

    return String(caip19.split(separator: ":", maxSplits: 2).last ?? "")
  }

  private func chainId(from caip2: String) -> Int {
    Int(caip2.split(separator: ":").last ?? "") ?? 0
  }

  private func rpcRequest(
    chainId: Int,
    method: String,
    params: [Any]
  ) async throws -> [String: Any] {
    let rpcURL = try getRpcURL(chainId: chainId)

    guard let url = URL(string: rpcURL) else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: rpcURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(
      withJSONObject: [
        "jsonrpc": "2.0",
        "id": 1,
        "method": method,
        "params": params
      ]
    )

    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      guard let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw RainSDKError.internalLogicError(
          details: "Unexpected RPC response payload for method \(method)"
        )
      }

      if let error = response["error"] as? [String: Any] {
        let code = error["code"] as? Int ?? -1
        let message = error["message"] as? String ?? "Unknown RPC error"
        throw NSError(
          domain: "eth.rpc",
          code: code,
          userInfo: [NSLocalizedDescriptionKey: message]
        )
      }

      return response
    } catch let error as RainSDKError {
      throw error
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  private func extractHexResult(
    from response: [String: Any],
    method: String
  ) throws -> String {
    guard let result = response["result"] as? String else {
      throw RainSDKError.internalLogicError(
        details: "Unexpected RPC result for method \(method)"
      )
    }

    return result
  }

  private func rpcTransactionObject(from params: WalletTransactionParams) -> [String: Any] {
    var transaction: [String: Any] = [
      "from": params.from,
      "to": params.to,
      "value": params.value
    ]

    if !params.data.isEmpty {
      transaction["data"] = params.data
    }

    return transaction
  }

  private func getRpcURL(chainId: Int) throws -> String {
    guard let networkConfig = networkConfigsByChainId[chainId] else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: "")
    }

    return networkConfig.rpcUrl
  }

  private func decimalStringToDouble(
    balance: String?,
    decimals: Int
  ) -> Double {
    guard let balance, !balance.isEmpty else {
      return 0
    }

    let value = NSDecimalNumber(string: balance)
    let divisor = NSDecimalNumber(
      mantissa: 1,
      exponent: Int16(decimals),
      isNegative: false
    )

    return value.dividing(by: divisor).doubleValue
  }

  private func decimalString(fromHex hex: String) -> String {
    let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
    guard let value = BigUInt(cleanHex, radix: 16) else {
      return "0"
    }

    return value.description
  }

  private func normalizedData(_ data: String) -> String {
    if data.isEmpty {
      return "0x"
    }

    return data
  }

  private static func iso8601String(from timestamp: TimeInterval) -> String {
    ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: timestamp))
  }

  private static func ethereumSignatureHex(from signature: SignRawPayloadResult) -> String {
    let r = normalizeHexComponent(signature.r, length: 64)
    let s = normalizeHexComponent(signature.s, length: 64)
    let v = String(format: "%02x", normalizedRecoveryId(signature.v))

    return "0x\(r)\(s)\(v)"
  }

  private static func normalizeHexComponent(_ value: String, length: Int) -> String {
    let clean = value
      .lowercased()
      .replacingOccurrences(of: "0x", with: "")
    if clean.count >= length {
      return String(clean.suffix(length))
    }

    return String(repeating: "0", count: length - clean.count) + clean
  }

  private static func normalizedRecoveryId(_ value: String) -> Int {
    let clean = value.lowercased()
    let parsedValue: Int?

    if clean.hasPrefix("0x") {
      parsedValue = Int(clean.dropFirst(2), radix: 16)
    } else if let decimal = Int(clean) {
      parsedValue = decimal
    } else {
      parsedValue = Int(clean, radix: 16)
    }

    guard let parsedValue else {
      return 27
    }

    return parsedValue >= 27 ? parsedValue : parsedValue + 27
  }
}
