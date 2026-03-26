import Foundation
import Web3
import Web3Core
import web3swift
import PortalSwift
import Web3ContractABI

/// Portal-based implementation of `RainWalletProvider`.
/// Used when the SDK is initialized with `initializePortal(...)`.
internal final class PortalWalletProviderAdapter: RainWalletProvider, @unchecked Sendable {
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
    let chainIdString = Constants.ChainIDFormat.EIP155.format(chainId: chainId)
    
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

  /// Fetches native token balance (e.g. ETH) via eth_getBalance and parses the RPC response (PortalProviderRpcResponse → result?.asDouble?.weiToEth).
  public func getNativeBalance(
    chainId: Int
  ) async throws -> Double {
    let walletAddress = try await address()
    let chainIdString = Constants.ChainIDFormat.EIP155.format(chainId: chainId)
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
    let chainIdString = Constants.ChainIDFormat.EIP155.format(chainId: chainId)
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

  /// Fetches ERC-20 token balances via Portal's getBalances and returns a contract-address-to-balance dictionary.
  public func getERC20Balances(
    chainId: Int
  ) async throws -> [String: Double] {
    let chainIdString = Constants.ChainIDFormat.EIP155.format(chainId: chainId)
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

  /// Fetches transaction history via Portal's getTransactions and maps to wallet-agnostic records.
  public func getTransactions(
    chainId: Int,
    limit: Int?,
    offset: Int?,
    order: WalletTransactionOrder?
  ) async throws -> [WalletTransaction] {
    let chainIdString = Constants.ChainIDFormat.EIP155.format(chainId: chainId)
    let portalOrder = order?.toPortalOrder
    let fetchedTransactions = try await portal.getTransactions(
      chainIdString,
      limit: limit,
      offset: offset,
      order: portalOrder
    )
    
    return fetchedTransactions.map(WalletTransaction.init)
  }
}
