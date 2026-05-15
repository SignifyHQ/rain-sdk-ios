import Foundation
import Web3

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
  /// Returns wallet address and wallet transaction params ready for fee estimation or submission.
  func buildTransactionParamForWithdrawAsset(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?
  ) async throws -> (walletAddress: String, transactionParams: WalletTransactionParams) {
    guard let provider = _walletProvider else {
      throw RainSDKError.sdkNotInitialized
    }

    guard let signerProvider = provider as? any RainTypedDataSignerProvider else {
      throw RainSDKError.internalLogicError(
        details: "Current wallet provider does not support EIP-712 signing"
      )
    }

    let walletAddress = try await provider.address()

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
    // Sign EIP-712 message using the active wallet provider to get the admin signature
    let adminSignatureString = try await signerProvider.signTypedData(
      chainId: chainId,
      walletAddress: walletAddress,
      typedData: eip712Message
    )

    // Convert salt hex string back to Data
    guard let adminSaltData = Data.fromHex(adminSaltHex) else {
      throw RainSDKError.internalLogicError(details: "Failed to convert admin salt hex string to Data")
    }
    
    guard let adminSignatureData = Data(hexString: adminSignatureString, length: 65)
    else {
      throw RainSDKError.internalLogicError(details: "Failed to convert admin signature hex string to Data or invalid length")
    }
    
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
    let transactionParams = WalletTransactionParams(
      from: walletAddress,
      to: assetAddresses.contractAddress,
      value: 0.ethToWei.toHexString,
      data: transactionData
    )
    
    return (walletAddress, transactionParams)
  }
  
  /// Estimates total transaction fee (estimated gas × gas price) in native token via the active wallet provider.
  /// // TODO consider EIP-1559 chains
  func estimateTransactionFee(chainId: Int, address: String, params: WalletTransactionParams) async throws -> Double {
    guard let provider = _walletProvider else {
      throw RainSDKError.sdkNotInitialized
    }

    guard let estimatingProvider = provider as? any RainTransactionFeeEstimatingProvider else {
      throw RainSDKError.internalLogicError(
        details: "Current wallet provider does not support fee estimation"
      )
    }

    return try await estimatingProvider.estimateTransactionFee(
      chainId: chainId,
      walletAddress: address,
      params: params
    )
  }
}
