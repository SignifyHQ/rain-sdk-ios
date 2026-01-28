import Foundation
import RainSDK
import Web3
import Web3Core
import web3swift
import PortalSwift

/// Service class for managing Rain SDK operations
@MainActor
class RainSDKService: ObservableObject {
  // MARK: - Singleton
  
  /// Shared instance of the service
  static let shared = RainSDKService()
  
  // MARK: - Properties
  
  /// The Rain SDK manager instance
  private let sdkManager = RainSDKManager()
  
  /// Current initialization state
  @Published var isInitialized = false
  
  // MARK: - Initialization
  
  private init() {}
  
  /// Current error state
  @Published var error: RainSDKError?
  
  /// Current initialization status message
  @Published var statusMessage: String = "Not initialized"
  
  // MARK: - Initialization
  
  /// Initialize the SDK with Portal token and network configurations
  /// - Parameters:
  ///   - portalToken: Portal session token
  ///   - networkConfigs: Array of network configurations
  func initialize(portalToken: String, networkConfigs: [NetworkConfig]) async {
    statusMessage = "Initializing..."
    error = nil
    
    do {
      // Enable logging for demo
      RainLogger.isEnabled = true
      
      try await sdkManager.initializePortal(
        portalSessionToken: portalToken,
        networkConfigs: networkConfigs
      )
      
      isInitialized = true
      statusMessage = "Initialized successfully with \(networkConfigs.count) network(s)"
      error = nil
    } catch let sdkError as RainSDKError {
      isInitialized = false
      error = sdkError
      statusMessage = "Initialization failed: \(sdkError.errorCode)"
    } catch {
      isInitialized = false
      self.error = RainSDKError.providerError(underlying: error)
      statusMessage = "Initialization failed: Unknown error"
    }
  }
  
  /// Initialize the SDK in wallet-agnostic mode (without Portal token)
  /// - Parameters:
  ///   - networkConfigs: Array of network configurations
  func initializeWalletAgnostic(networkConfigs: [NetworkConfig]) async {
    statusMessage = "Initializing (wallet-agnostic)..."
    error = nil
    
    do {
      // Enable logging for demo
      RainLogger.isEnabled = true
      
      try await sdkManager.initialize(networkConfigs: networkConfigs)
      
      isInitialized = true
      statusMessage = "Initialized successfully (wallet-agnostic) with \(networkConfigs.count) network(s)"
      error = nil
    } catch let sdkError as RainSDKError {
      isInitialized = false
      error = sdkError
      statusMessage = "Initialization failed: \(sdkError.errorCode)"
    } catch {
      isInitialized = false
      self.error = RainSDKError.providerError(underlying: error)
      statusMessage = "Initialization failed: Unknown error"
    }
  }
  
  // MARK: - Transaction Building Methods
  
  /// Build EIP-712 message
  func buildEIP712Message(
    chainId: Int,
    collateralProxyAddress: String,
    walletAddress: String,
    tokenAddress: String,
    amount: Double,
    decimals: Int,
    recipientAddress: String,
    nonce: BigUInt?
  ) async throws -> (String, String) {
    return try await sdkManager.buildEIP712Message(
      chainId: chainId,
      collateralProxyAddress: collateralProxyAddress,
      walletAddress: walletAddress,
      tokenAddress: tokenAddress,
      amount: amount,
      decimals: decimals,
      recipientAddress: recipientAddress,
      nonce: nonce
    )
  }
  
  /// Build withdraw transaction data
  func buildWithdrawTransactionData(
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
    return try await sdkManager.buildWithdrawTransactionData(
      chainId: chainId,
      contractAddress: contractAddress,
      proxyAddress: proxyAddress,
      tokenAddress: tokenAddress,
      amount: amount,
      decimals: decimals,
      recipientAddress: recipientAddress,
      expiresAt: expiresAt,
      signatureData: signatureData,
      adminSalt: adminSalt,
      adminSignature: adminSignature
    )
  }
  
  // MARK: - Portal Access
  
  /// Check if SDK is initialized
  var hasPortal: Bool {
    do {
      _ = try sdkManager.portal
      return true
    } catch {
      return false
    }
  }
  
  // MARK: - Reset
  
  /// Reset the SDK state
  func reset() {
    isInitialized = false
    error = nil
    statusMessage = "Reset"
  }
}
