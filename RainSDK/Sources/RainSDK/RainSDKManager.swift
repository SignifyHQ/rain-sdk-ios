import Foundation
import PortalSwift
import Web3
import Web3Core
import web3swift

public final class RainSDKManager: RainSDK {
  // MARK: - Properties

  // Internal storage for Portal instance
  private var _portal: Portal?
  
  // Transaction builder service
  private var _transactionBuilder: TransactionBuilderProtocol?
  
  private var _networkConfigs: [NetworkConfig] = []
  
  /// Computed property to safely access the Portal instance
  public var portal: Portal {
    get throws {
      guard let portal = _portal
      else {
        throw RainSDKError.sdkNotInitialized
      }
      
      return portal
    }
  }
  
  // MARK: - Initialization
  public init() {}
  
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
      
      // Store portal instance
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
    collateralProxyAddress: String,
    walletAddress: String,
    tokenAddress: String,
    amount: Double,
    decimals: Int,
    recipientAddress: String,
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
        proxyAddress: collateralProxyAddress,
        chainId: chainId
      )
      
      RainLogger.debug("Rain SDK: Retrieved nonce \(finalNonce) from contract")
    }
    
    // Amount is already in smallest units (as per protocol documentation)
    // Convert Double to BigUInt
    let amountBaseUnits = BigUInt(amount * pow(10.0, Double(decimals)))
    
    // Build EIP-712 message using service
    let jsonMessage = try transactionBuilder.buildEIP712Message(
      chainId: chainId,
      collateralProxyAddress: collateralProxyAddress,
      walletAddress: walletAddress,
      tokenAddress: tokenAddress,
      amount: amountBaseUnits,
      recipientAddress: recipientAddress,
      nonce: finalNonce,
      salt: salt
    )
    
    return (jsonMessage, salt.toHexString())
  }
  
  public func buildWithdrawTransactionData(
    chainId: Int,
    contractAddress: String,
    proxyAddress: String,
    tokenAddress: String,
    amount: Double,
    decimals: Int,
    recipientAddress: String,
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
    guard let ethereumContractAddress = Web3Core.EthereumAddress(contractAddress),
          let ethereumProxyAddress = Web3Core.EthereumAddress(proxyAddress),
          let ethereumTokenAddress = Web3Core.EthereumAddress(tokenAddress),
          let ethereumRecipientAddress = Web3Core.EthereumAddress(recipientAddress)
    else {
      RainLogger.error("Rain SDK: Error building transaction parameters for withdrawal. One of the addresses could not be built")
      throw RainSDKError.internalLogicError(
        details: "Error building transaction parameters for withdrawal. One of the addresses could not be built"
      )
    }
    
    // Convert the amount to base units using decimals of the token
    let amountBaseUnits = BigUInt(amount * pow(10.0, Double(decimals)))
    
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
    amount: Double,
    transactionData: String
  ) -> ETHTransactionParam {
    return ETHTransactionParam(
      from: walletAddress,
      to: contractAddress,
      value: amount.ethToWei.toHexString,
      data: transactionData
    )
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
