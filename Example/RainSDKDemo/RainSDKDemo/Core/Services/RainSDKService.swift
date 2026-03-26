import Foundation
import UIKit
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
      
      // Fetch the wallet address to ensure the session token is valid
      print("Rain SDK: wallet address \(try await sdkManager.getWalletAddress())")
      
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
    let assetAddresses = EIP712AssetAddresses(
      proxyAddress: collateralProxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
    return try await sdkManager.buildEIP712Message(
      chainId: chainId,
      walletAddress: walletAddress,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
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
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: contractAddress,
      proxyAddress: proxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
    return try await sdkManager.buildWithdrawTransactionData(
      chainId: chainId,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      expiresAt: expiresAt,
      salt: adminSalt,
      signatureData: signatureData,
      adminSalt: adminSalt,
      adminSignature: adminSignature
    )
  }
  
  // MARK: - Wallet Address & QR

  /// Returns the current wallet address from the wallet provider.
  func getWalletAddress() async throws -> String {
    try await sdkManager.getWalletAddress()
  }

  /// Generates a QR code image (PNG) encoding the current wallet address.
  func generateWalletAddressQRCode(
    dimension: Int = 256,
    backgroundColor: CGColor? = nil,
    foregroundColor: CGColor? = nil
  ) async throws -> Data {
    try await sdkManager.generateWalletAddressQRCode(
      dimension: dimension,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor
    )
  }

  /// Fetches the native token balance (e.g. ETH, AVAX) for the current wallet on the given network.
  func getNativeBalance(chainId: Int) async throws -> Double {
    try await sdkManager.getNativeBalance(chainId: chainId)
  }

  /// Fetches the ERC-20 balance for a single token via direct RPC `eth_call` (balanceOf).
  func getERC20Balance(chainId: Int, tokenAddress: String, decimals: Int? = nil) async throws -> Double {
    try await sdkManager.getERC20Balance(chainId: chainId, tokenAddress: tokenAddress, decimals: decimals)
  }

  /// Fetches all balances (native + ERC-20) for the current wallet on the given network. Native balance uses key "".
  func getBalances(chainId: Int) async throws -> [String: Double] {
    try await sdkManager.getBalances(chainId: chainId)
  }

  /// Fetches transaction history for the current wallet on the given network.
  func getTransactions(
    chainId: Int,
    limit: Int? = nil,
    offset: Int? = nil,
    order: WalletTransactionOrder? = nil
  ) async throws -> [WalletTransaction] {
    try await sdkManager.getTransactions(
      chainId: chainId,
      limit: limit,
      offset: offset,
      order: order
    )
  }

  /// Sends native tokens (e.g. ETH, AVAX) from the current wallet.
  func sendNativeToken(chainId: Int, to: String, amount: Double) async throws -> String {
    try await sdkManager.sendNativeToken(chainId: chainId, to: to, amount: amount)
  }

  /// Sends ERC-20 tokens from the current wallet.
  func sendERC20Token(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Double,
    decimals: Int
  ) async throws -> String {
    try await sdkManager.sendERC20Token(
      chainId: chainId,
      contractAddress: contractAddress,
      to: to,
      amount: amount,
      decimals: decimals
    )
  }

  // MARK: - Portal Withdraw

  /// Execute collateral withdrawal via Portal (build, sign, submit). Requires Portal to be initialized.
  func withdrawCollateral(
    chainId: Int,
    contractAddress: String,
    proxyAddress: String,
    tokenAddress: String,
    recipientAddress: String,
    amount: Double,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?
  ) async throws -> String {
    let assetAddresses = WithdrawAssetAddresses(
      contractAddress: contractAddress,
      proxyAddress: proxyAddress,
      recipientAddress: recipientAddress,
      tokenAddress: tokenAddress
    )
    return try await sdkManager.withdrawCollateral(
      chainId: chainId,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      salt: salt,
      signature: signature,
      expiresAt: expiresAt,
      nonce: nonce
    )
  }

  // MARK: - Portal Withdraw View Model

  /// Returns a new Portal Withdraw demo view model for use in navigation or other screens.
  func makePortalWithdrawDemoViewModel() -> PortalWithdrawDemoViewModel {
    PortalWithdrawDemoViewModel()
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

  /// Recovers the Portal wallet from backup.
  /// - Parameters:
  ///   - backupMethod: `.iCloud` or `.PIN` (password).
  ///   - password: Required when backupMethod is `.PIN` (password); passed to `portal.setPassword` before recover.
  ///   - cipherText: Encrypted backup data (e.g. from iCloud or password storage).
  func recover(
    backupMethod: BackupMethods,
    password: String? = nil,
    cipherText: String
  ) async throws {
    let portal = try getPortal()

    if let password, backupMethod == .Password {
      try portal.setPassword(password)
    }

    do {
      _ = try await portal.recoverWallet(backupMethod, withCipherText: cipherText) { status in
        print("Rain SDK: Recover status: \(status)")
      }
      print("Rain SDK: Wallet recover success")
    } catch {
      print("Rain SDK: Recover failed - \(error.localizedDescription)")
      throw RainSDKError.providerError(underlying: error)
    }
  }

  private func getPortal() throws -> Portal {
    do {
      return try sdkManager.portal
    } catch {
      throw RainSDKError.sdkNotInitialized
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
