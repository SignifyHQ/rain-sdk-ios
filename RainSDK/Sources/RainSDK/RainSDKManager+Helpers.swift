import Foundation
import PortalSwift
import Web3
import Web3Core
import web3swift
import Web3ContractABI

// MARK: Internal Helpers
extension RainSDKManager {
  /// Validate input parameters before Portal initialization
  func validateInputs(
    portalSessionToken: String,
    networkConfigs: [NetworkConfig]
  ) throws {
    // Validate token
    guard !portalSessionToken.isEmpty else {
      RainLogger.warning("Rain SDK: Empty portal session token provided")
      throw RainSDKError.unauthorized
    }
    
    // Validate network configs
    try validateNetworkConfigs(networkConfigs)
  }
  
  /// Validate network configurations
  func validateNetworkConfigs(_ networkConfigs: [NetworkConfig]) throws {
    guard !networkConfigs.isEmpty else {
      RainLogger.warning("Rain SDK: Empty network configs provided")
      throw RainSDKError.invalidConfig(chainId: 0, rpcUrl: "")
    }
    
    // Validate each network config
    for networkConfig in networkConfigs {
      guard networkConfig.chainId > 0 else {
        throw RainSDKError.invalidConfig(chainId: networkConfig.chainId, rpcUrl: networkConfig.rpcUrl)
      }
      
      guard networkConfig.rpcUrl.isValidHTTPURL() else {
        throw RainSDKError.invalidConfig(chainId: networkConfig.chainId, rpcUrl: networkConfig.rpcUrl)
      }
    }
  }
  
  /// Build RPC configuration dictionary from NetworkConfig array
  func buildRpcConfig(from networkConfigs: [NetworkConfig]) throws -> [String: String] {
    var config: [String: String] = [:]
    
    for networkConfig in networkConfigs {
      // Validate chain ID
      guard networkConfig.chainId > 0 else {
        throw RainSDKError.invalidConfig(chainId: networkConfig.chainId, rpcUrl: networkConfig.rpcUrl)
      }
      
      // Validate RPC URL format
      guard networkConfig.rpcUrl.isValidHTTPURL() else {
        throw RainSDKError.invalidConfig(chainId: networkConfig.chainId, rpcUrl: networkConfig.rpcUrl)
      }
      
      // Use the eip155ChainId property from NetworkConfig
      config[networkConfig.eip155ChainId] = networkConfig.rpcUrl
      
      RainLogger.debug("Rain SDK: Added network config - Chain ID: \(networkConfig.chainId), RPC: \(networkConfig.rpcUrl)")
    }
    
    return config
  }
  
  /// Builds withdrawal transaction params: EIP-712 message, admin signature via Portal, and calldata.
  /// Returns wallet address and ETHTransactionParam ready for fee estimation or submission.
  func buildTransactionParamForWithdrawAsset(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?
  ) async throws -> (walletAddress: String, transactionParams: ETHTransactionParam) {
    guard let walletAddress = try await portalForRequest.addresses[PortalNamespace.eip155] ?? nil
    else {
      throw RainSDKError.internalLogicError(details: "No wallet address found in Portal")
    }
    
    let chainIdString = Constants.ChainIDFormat.EIP155.format(chainId: chainId)

    guard let withdrawalSaltData = Data(base64Encoded: salt) else {
      throw RainSDKError.internalLogicError(details: "Failed to convert withdrawal salt base 64 string to Data")
    }
    
    guard let withdrawalSignatureData = Data(hexString: signature, length: 65)
    else {
      throw RainSDKError.internalLogicError(details: "Failed to convert withdrawal signature hex string to Data")
    }
    
    // Convert to EIP712AssetAddresses for building the message
    let eip712Addresses = EIP712AssetAddresses(
      proxyAddress: assetAddresses.proxyAddress,
      recipientAddress: assetAddresses.recipientAddress,
      tokenAddress: assetAddresses.tokenAddress
    )
    // Build EIP-712 message to get admin signature
    let (eip712Message, adminSaltHex) = try await buildEIP712Message(
      chainId: chainId,
      walletAddress: walletAddress,
      assetAddresses: eip712Addresses,
      amount: amount,
      decimals: decimals,
      nonce: nonce
    )
    // Sign EIP-712 message using Portal to get admin signature
    let response = try await portalForRequest.request(
      chainId: chainIdString,
      method: .eth_signTypedData_v4,
      params: [walletAddress, eip712Message],
      options: nil
    )
    // Convert salt hex string back to Data
    guard let adminSaltData = Data.fromHex(adminSaltHex) else {
      throw RainSDKError.internalLogicError(details: "Failed to convert admin salt hex string to Data")
    }
    
    guard let adminSignatureString = (response.result as? String),
          let adminSignatureData = Data(hexString: adminSignatureString, length: 65)
    else {
      throw RainSDKError.internalLogicError(details: "Failed to convert admin signature hex string to Data or invalid length")
    }
    
    print("zzzzz \(withdrawalSignatureData.count) \(adminSignatureData.count) \(withdrawalSaltData.count)")
    let transactionData = try await buildWithdrawTransactionData(
      chainId: chainId,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      expiresAt: expiresAt,
      salt: withdrawalSaltData,
      signatureData: withdrawalSignatureData,
      adminSalt: adminSaltData,
      adminSignature: adminSignatureData
    )
    
    // Prepare transaction parameters for Portal
    let transactionParams = composeTransactionParameters(
      walletAddress: walletAddress,
      contractAddress: assetAddresses.contractAddress,
      transactionData: transactionData
    )
    
    return (walletAddress, transactionParams)
  }
  
  /// Estimates total transaction fee (estimated gas × gas price) in native token via Portal RPC.
  func estimateTransactionFee(chainId: Int, address: String, params: ETHTransactionParam) async throws -> Double {
    // Fetch estimated gas for the transaction
    let estimateGas = try await fetchGasData(chainId: chainId, method: .eth_estimateGas, address: address, params: [params])
    
    // Fetch current gas price
    let gasPrice = try await fetchGasData(chainId: chainId, method: .eth_gasPrice, address: address).weiToEth
    
    // Calculate the total fees
    let txFee: Double = estimateGas * gasPrice
    
    return(txFee)
  }
  
  /// Fetches gas-related RPC result (e.g. eth_estimateGas, eth_gasPrice) via Portal; returns numeric value as Double.
  ///
  /// The underlying `PortalProviderResult.result` can come back in different shapes depending on
  /// the Portal SDK / transport. This helper supports:
  /// - `PortalProviderRpcResponse` whose `result` is a `String` that can be parsed as `Double`
  /// - a raw `String` that can be parsed as `Double`
  /// - a raw numeric type (`NSNumber` / `Double`)
  func fetchGasData(chainId: Int, method: PortalRequestMethod, address: String, params: [Any] = []) async throws -> Double {
    let chainIdString = Constants.ChainIDFormat.EIP155.format(chainId: chainId)
    
    let response = try await portalForRequest.request(
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
