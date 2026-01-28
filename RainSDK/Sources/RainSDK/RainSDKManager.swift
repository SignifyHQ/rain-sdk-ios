import Foundation
import PortalSwift
import Web3
import Web3Core
import web3swift
import Web3ContractABI

public final class RainSDKManager: RainSDK {
  // MARK: - Properties

  // Internal storage for Portal instance (using protocol for testability)
  private var _portal: PortalRequestProtocol?
  
  // Transaction builder service
  private var _transactionBuilder: TransactionBuilderProtocol?
  
  private var _networkConfigs: [NetworkConfig] = []
  
  /// Computed property to safely access the Portal instance
  /// Returns Portal (concrete type) for public API compatibility
  public var portal: Portal {
    get throws {
      guard let portalProtocol = _portal
      else {
        throw RainSDKError.sdkNotInitialized
      }
      
      // Cast to Portal for public API
      guard let portal = portalProtocol as? Portal
      else {
        throw RainSDKError.sdkNotInitialized
      }
      
      return portal
    }
  }
  
  // MARK: - Initialization
  public init() {}
  
  /// Internal initializer for testing - allows injecting a custom transaction builder
  internal init(transactionBuilder: TransactionBuilderProtocol?) {
    self._transactionBuilder = transactionBuilder
  }
  
  /// Internal initializer for testing - allows injecting both Portal and transaction builder
  internal init(portal: PortalRequestProtocol?, transactionBuilder: TransactionBuilderProtocol?) {
    self._portal = portal // Portal conforms to PortalRequestProtocol via extension
    self._transactionBuilder = transactionBuilder
  }
  
  /// Internal initializer for testing - allows injecting a PortalRequestProtocol mock
  internal init(portalProtocol: PortalRequestProtocol?, transactionBuilder: TransactionBuilderProtocol?) {
    self._portal = portalProtocol
    self._transactionBuilder = transactionBuilder
  }
  
  public func initializePortal(
    portalSessionToken: String,
    networkConfigs: [NetworkConfig]
  ) async throws {
    // Validate inputs
    try validateInputs(portalSessionToken: portalSessionToken, networkConfigs: networkConfigs)
    
    // Store network configs
    _networkConfigs = networkConfigs
    
    // Convert network configs to Portal format
    let eip155RpcEndpointsConfig = try buildRpcConfig(from: networkConfigs)
    
    do {
      // Initialize Portal instance
      let portal = try Portal(
        portalSessionToken,
        withRpcConfig: eip155RpcEndpointsConfig,
        autoApprove: true,
        iCloud: ICloudStorage(),
        keychain: PortalKeychain(),
        passwords: PasswordStorage()
      )
      
      // Store portal instance (Portal conforms to PortalProtocol via extension)
      _portal = portal
      
      // Initialize transaction builder service with network configs
      _transactionBuilder = TransactionBuilderService(networkConfigs: networkConfigs)
      
      let addresses = try await portal.addresses
      RainLogger.info("Rain SDK: Portal initialized with \(addresses.count) wallet address(es)")
      RainLogger.info("Rain SDK: Registered Portal instance successfully with \(networkConfigs.count) network(s)")
    } catch let error as RainSDKError {
      RainLogger.error("Rain SDK: Initialization error - \(error.localizedDescription)")
      throw error
    } catch {
      RainLogger.error("Rain SDK: Portal SDK error - \(error.localizedDescription)")
      throw RainSDKError.providerError(underlying: error)
    }
  }
  
  public func initialize(
    networkConfigs: [NetworkConfig]
  ) async throws {
    // Validate network configs
    try validateNetworkConfigs(networkConfigs)
    
    // Store network configs
    _networkConfigs = networkConfigs
    
    // Initialize transaction builder service with network configs
    _transactionBuilder = TransactionBuilderService(networkConfigs: networkConfigs)
    
    RainLogger.info("Rain SDK: Initialized in wallet-agnostic mode with \(networkConfigs.count) network(s)")
  }
  
  public func buildEIP712Message(
    chainId: Int,
    walletAddress: String,
    assetAddresses: EIP712AssetAddresses,
    amount: Double,
    decimals: Int,
    nonce: BigUInt?
  ) async throws -> (String, String) {
    // Ensure SDK is initialized with network configs
    guard let transactionBuilder = _transactionBuilder else {
      throw RainSDKError.sdkNotInitialized
    }
    
    // Generate or reuse salt (store internally for later use in transaction building)
    let salt = transactionBuilder.generateSalt()
    
    // Get nonce - retrieve from network if not provided
    let finalNonce: BigUInt
    if let providedNonce = nonce {
      finalNonce = providedNonce
    } else {
      // Retrieve nonce from contract
      finalNonce = try await transactionBuilder.getLatestNonce(
        proxyAddress: assetAddresses.proxyAddress,
        chainId: chainId
      )
      RainLogger.debug("Rain SDK: Retrieved nonce \(finalNonce) from contract")
    }
    
    // Amount is already in smallest units (as per protocol documentation)
    // Convert Double to BigUInt
    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    
    // Build EIP-712 message using service
    let jsonMessage = try transactionBuilder.buildEIP712Message(
      chainId: chainId,
      collateralProxyAddress: assetAddresses.proxyAddress,
      walletAddress: walletAddress,
      tokenAddress: assetAddresses.tokenAddress,
      amount: amountBaseUnits,
      recipientAddress: assetAddresses.recipientAddress,
      nonce: finalNonce,
      salt: salt
    )
    return (jsonMessage, salt.toHexString())
  }
  
  public func buildWithdrawTransactionData(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    expiresAt: String,
    signatureData: Data,
    adminSalt: Data,
    adminSignature: Data
  ) async throws -> String {
    // Ensure SDK is initialized with network configs
    guard let transactionBuilder = _transactionBuilder else {
      throw RainSDKError.sdkNotInitialized
    }
    
    // Convert string addresses to Web3Core.EthereumAddress objects
    guard let ethereumContractAddress = Web3Core.EthereumAddress(assetAddresses.contractAddress),
          let ethereumProxyAddress = Web3Core.EthereumAddress(assetAddresses.proxyAddress),
          let ethereumTokenAddress = Web3Core.EthereumAddress(assetAddresses.tokenAddress),
          let ethereumRecipientAddress = Web3Core.EthereumAddress(assetAddresses.recipientAddress)
    else {
      RainLogger.error("Rain SDK: Error building transaction parameters for withdrawal. One of the addresses could not be built")
      throw RainSDKError.internalLogicError(
        details: "Error building transaction parameters for withdrawal. One of the addresses could not be built"
      )
    }
    
    // Convert the amount to base units using decimals of the token
    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    
    // Convert the expiration timestamp string from Rain API to Unix Timestamp
    // Expects ISO8601 format or Unix timestamp string
    let unixTimestamp: Int
    if let timestamp = Int(expiresAt) {
      unixTimestamp = timestamp
    } else if let date = ISO8601DateFormatter().date(from: expiresAt) {
      unixTimestamp = Int(date.timeIntervalSince1970)
    } else {
      RainLogger.error("Rain SDK: Error building transaction parameters for withdrawal. Could not parse expiration to UNIX timestamp")
      throw RainSDKError.internalLogicError(
        details: "Invalid expiration timestamp format. Expected ISO8601 or Unix timestamp string"
      )
    }
    
    // Build WithdrawAssetParameter struct
    let withdrawAssetParameter = WithdrawAssetParameter(
      proxyAddress: ethereumProxyAddress,
      tokenAddress: ethereumTokenAddress,
      amount: amountBaseUnits,
      recipientAddress: ethereumRecipientAddress,
      expiryAt: BigUInt(unixTimestamp),
      salt: adminSalt,
      signature: signatureData,
      adminSalt: adminSalt,
      adminSignature: adminSignature
    )
    
    // Build transaction data using service
    return try await transactionBuilder.buildErc20TransactionForWithdrawAsset(
      chainId: chainId,
      ethereumContractAddress: ethereumContractAddress,
      withdrawAssetParameter: withdrawAssetParameter
    )
  }
  
  public func composeTransactionParameters(
    walletAddress: String,
    contractAddress: String,
    transactionData: String
  ) -> ETHTransactionParam {
    return ETHTransactionParam(
      from: walletAddress,
      to: contractAddress,
      value: 0.ethToWei.toHexString,
      data: transactionData
    )
  }
  
  public func withdrawCollateral(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?
  ) async throws -> String {
    // Get wallet address from Portal (using protocol internally)
    guard let portal = _portal
    else {
      throw RainSDKError.sdkNotInitialized
    }
    
    guard let walletAddress = try await portal.addresses[PortalNamespace.eip155] ?? nil
    else {
      throw RainSDKError.internalLogicError(details: "No wallet address found in Portal")
    }
    
    let chainIdString = "eip155:\(chainId)"
    
    // Convert to EIP712AssetAddresses for building the message
    let eip712Addresses = EIP712AssetAddresses(
      proxyAddress: assetAddresses.proxyAddress,
      recipientAddress: assetAddresses.recipientAddress,
      tokenAddress: assetAddresses.tokenAddress
    )
    
    // Build EIP-712 message to get admin signature
    let (eip712Message, saltHex) = try await buildEIP712Message(
      chainId: chainId,
      walletAddress: walletAddress,
      assetAddresses: eip712Addresses,
      amount: amount,
      decimals: decimals,
      nonce: nonce
    )
    // Sign EIP-712 message using Portal to get admin signature
    // Convert salt hex string back to Data
    guard let saltData = Data(base64Encoded: saltHex) else {
      throw RainSDKError.internalLogicError(details: "Failed to convert salt hex string to Data")
    }
    
    // Sign the EIP-712 message using Portal
    let response = try await portal.request(
      chainId: chainIdString,
      method: .eth_signTypedData_v4,
      params: [walletAddress, eip712Message],
      options: nil
    )
    
    guard let adminSignatureString = (response.result as? String),
          let adminSignatureData = Data(hexString: adminSignatureString, length: 65)
    else {
      throw RainSDKError.internalLogicError(details: "Failed to convert admin signature hex string to Data or invalid length")
    }
    
    guard let signatureData = Data(base64Encoded: signature)
    else {
      throw RainSDKError.internalLogicError(details: "Failed to convert user signature hex string to Data")
    }
    
    let transactionData = try await buildWithdrawTransactionData(
      chainId: chainId,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      expiresAt: expiresAt,
      signatureData: signatureData,
      adminSalt: saltData,
      adminSignature: adminSignatureData
    )
    
    // Prepare transaction parameters for Portal
    let transactionParams = composeTransactionParameters(
      walletAddress: walletAddress,
      contractAddress: assetAddresses.contractAddress,
      transactionData: transactionData
    )
    
    // Sign and send transaction using Portal
    let ethSendResponse = try await portal.request(
      chainId: chainIdString,
      method: .eth_sendTransaction,
      params: [transactionParams],
      options: nil
    )
    let txHash = ethSendResponse.result as? String ?? "-/-"
    
    RainLogger.info("Rain SDK: Withdrawal transaction submitted. Hash: \(txHash)")
    return txHash
  }
}

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
}
