import Foundation
import Web3
import Web3Core
import web3swift

/// Service for building transaction components
/// Handles EIP-712 message generation, contract interactions, and ABI management
final class TransactionBuilderService: TransactionBuilderProtocol {
  // MARK: - Properties
  
  private let networkConfigs: [NetworkConfig]
  private let networkConfigsByChainId: [Int: NetworkConfig]
  
  // MARK: - Initialization
  
  init(networkConfigs: [NetworkConfig]) {
    self.networkConfigs = networkConfigs
    self.networkConfigsByChainId = Dictionary(uniqueKeysWithValues: 
      networkConfigs.map { ($0.chainId, $0) })
  }
  
  // MARK: - Salt Generation
  
  /// Generate random 32-byte salt for EIP-712 domain
  func generateSalt() -> Data {
    var randomBytes = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    return Data(randomBytes)
  }
  
  // MARK: - Nonce Retrieval
  
  /// Get latest nonce from contract
  func getLatestNonce(
    proxyAddress: String,
    chainId: Int
  ) async throws -> BigUInt {
    let rpcURL = try getRpcURL(chainId: chainId)
    let collateralJsonABI = try getCollateralJsonABI()
    
    guard let url = URL(string: rpcURL),
          let ethereumCollateralAddress = Web3Core.EthereumAddress(proxyAddress)
    else {
      RainLogger.error("Rain SDK: Error getting contract's nonce. Could not build proxy address or RPC URL is missing")
      throw RainSDKError.internalLogicError(
        details: "Invalid proxy address or RPC URL for chain ID \(chainId)"
      )
    }
    
    do {
      let web3 = try await Web3.new(url)
      let contract = web3.contract(
        collateralJsonABI,
        at: ethereumCollateralAddress,
        abiVersion: 2
      )
      
      let response = try await contract?
        .createReadOperation("adminNonce")?
        .callContractMethod()
      
      guard let nonce = response?["0"] as? BigUInt
      else {
        RainLogger.error("Rain SDK: Error getting contract's nonce. Nonce is missing in the response")
        throw RainSDKError.internalLogicError(
          details: "Nonce not found in contract response for proxy address \(proxyAddress)"
        )
      }
      
      return nonce
    } catch let error as RainSDKError {
      throw error
    } catch {
      RainLogger.error("Rain SDK: Error calling contract for nonce - \(error.localizedDescription)")
      throw RainSDKError.providerError(underlying: error)
    }
  }
  
  // MARK: - EIP-712 Message Building
  
  /// Build EIP-712 message structure
  func buildEIP712Message(
    chainId: Int,
    collateralProxyAddress: String,
    walletAddress: String,
    tokenAddress: String,
    amount: BigUInt,
    recipientAddress: String,
    nonce: BigUInt,
    salt: String
  ) throws -> String {
    // Build EIP-712 domain
    let domain: [String: Any] = [
      "name": "Collateral",
      "version": "2",
      "chainId": chainId,
      "verifyingContract": collateralProxyAddress,
      "salt": salt
    ]
    
    // Build EIP-712 types
    let types: [String: Any] = [
      "EIP712Domain": [
        ["name": "name", "type": "string"],
        ["name": "version", "type": "string"],
        ["name": "chainId", "type": "uint256"],
        ["name": "verifyingContract", "type": "address"],
        ["name": "salt", "type": "bytes32"]
      ],
      "Withdraw": [
        ["name": "user", "type": "address"],
        ["name": "asset", "type": "address"],
        ["name": "amount", "type": "uint256"],
        ["name": "recipient", "type": "address"],
        ["name": "nonce", "type": "uint256"]
      ]
    ]
    
    // Build message
    let message: [String: Any] = [
      "user": walletAddress,
      "asset": tokenAddress,
      "amount": amount.description,
      "recipient": recipientAddress,
      "nonce": nonce.description
    ]
    
    // Build complete EIP-712 message
    let messageToSign: [String: Any] = [
      "types": types,
      "domain": domain,
      "primaryType": "Withdraw",
      "message": message
    ]
    
    // Serialize to JSON
    let jsonData = try JSONSerialization.data(
      withJSONObject: messageToSign,
      options: [.sortedKeys]
    )
    
    guard let messageString = String(data: jsonData, encoding: .utf8) else {
      RainLogger.error("Rain SDK: Error building EIP-712 message. Could not build message string")
      throw RainSDKError.internalLogicError(
        details: "Failed to serialize EIP-712 message to JSON"
      )
    }
    
    RainLogger.debug("Rain SDK: Built EIP-712 message for chain \(chainId)")
    return messageString
  }
  
  /// Build withdraw transaction data
  func buildErc20TransactionForWithdrawAsset(
    chainId: Int,
    ethereumContractAddress: Web3Core.EthereumAddress,
    withdrawAssetParameter: WithdrawAssetParameter
  ) async throws -> String {
    let rpcURL = try getRpcURL(chainId: chainId)
    let contractJsonABI = try getContractJsonABI()
    
    guard let url = URL(string: rpcURL) else {
      RainLogger.error("Rain SDK: Error building transaction for withdrawal. RPC URL is missing")
      throw RainSDKError.internalLogicError(
        details: "RPC URL is missing for chain ID \(chainId)"
      )
    }
    
    let web3 = try await Web3.new(url)
    let contract = web3.contract(
      contractJsonABI,
      at: ethereumContractAddress,
      abiVersion: 2
    )
    print("zzzzz \(withdrawAssetParameter.adminSignature.count)")
    guard let tx = contract?
      .createWriteOperation(
        "withdrawAsset",
        parameters: [
          withdrawAssetParameter.proxyAddress,
          withdrawAssetParameter.tokenAddress,
          withdrawAssetParameter.amount,
          withdrawAssetParameter.recipientAddress,
          withdrawAssetParameter.expiryAt,
          withdrawAssetParameter.salt,
          withdrawAssetParameter.signature,
          [withdrawAssetParameter.adminSalt],
          [withdrawAssetParameter.adminSignature],
          true
        ]
      )?
      .data?
      .toHexString()
    else {
      RainLogger.error("Rain SDK: Error building transaction for withdrawal. Could not encode withdrawAsset contract function")
      throw RainSDKError.internalLogicError(
        details: "Failed to encode withdrawAsset contract function"
      )
    }
    
    return "0x" + tx
  }
}

// MARK: - Helpers

private extension TransactionBuilderService {
  /// Get RPC URL for a specific chain ID
  /// - Parameter chainId: The chain identifier
  /// - Returns: RPC URL string
  /// - Throws: RainSDKError if RPC URL not found
  func getRpcURL(chainId: Int) throws -> String {
    guard let config = networkConfigsByChainId[chainId] else {
      RainLogger.error("Rain SDK: Error getting RPC URL. Chain ID \(chainId) not found in network configs")
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: "")
    }
    
    guard config.rpcUrl.isValidHTTPURL() else {
      RainLogger.error("Rain SDK: Error getting RPC URL. Invalid RPC URL for chain ID \(chainId)")
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: config.rpcUrl)
    }
    
    return config.rpcUrl
  }
  
  /// Get contract ABI JSON string
  /// - Returns: Contract ABI JSON string
  /// - Throws: RainSDKError if ABI file not found
  func getContractJsonABI() throws -> String {
    guard let contractABIJsonString = FileHelpers.readJSONFile(
      forName: Constants.ContractABI.contractJsonABI,
      type: String.self
    ) else {
      RainLogger.error("Rain SDK: Error getting contract ABI. ABI file not found: \(Constants.ContractABI.contractJsonABI).json")
      throw RainSDKError.internalLogicError(details: "Contract ABI file not found.")
    }
    
    return contractABIJsonString
  }
  
  /// Get collateral contract ABI JSON string
  /// - Returns: Collateral ABI JSON string
  /// - Throws: RainSDKError if ABI file not found
  func getCollateralJsonABI() throws -> String {
    guard let collateralABIJsonString = FileHelpers.readJSONFile(
      forName: Constants.ContractABI.collateralJsonABI,
      type: String.self
    ) else {
      RainLogger.error("Rain SDK: Error getting collateral ABI. ABI file not found: \(Constants.ContractABI.collateralJsonABI).json")
      throw RainSDKError.internalLogicError(details: "Collateral ABI file not found.")
    }
    
    return collateralABIJsonString
  }
}
