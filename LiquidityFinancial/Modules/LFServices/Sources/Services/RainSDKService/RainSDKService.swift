import Foundation
import PortalSwift
import Factory
import RainSDK
import BigInt
import LFUtilities

public class RainSDKService: PortalServiceProtocol {
  // MARK: Injections
  @LazyInjected(\.environmentService) private var environmentService
  @LazyInjected(\.cloudKitService) private var cloudKitService
  
  // MARK: Private properties
  private let base: PortalServiceProtocol
  private let rainSDKManager = RainSDKManager()
  
  // MARK: Public properties
  public var portal: Portal?
  public var chainId: Int = 0
  public var walletAddress: String? {
    portal?.address
  }
  
  public init(
    base: PortalServiceProtocol
  ) {
    self.base = base
  }
  
  public func registerPortal(
    sessionToken: String
  ) async throws {
    let config = environmentService.networkEnvironment == .productionLive
    ? Configs.PortalNetwork.avalancheMainnet
    : Configs.PortalNetwork.avalancheFuji
    chainId = config.chainID
    let rcpPath = config.rcpPath
    
    let networkConfigs: [NetworkConfig] = [
      .init(chainId: chainId, rpcUrl: rcpPath)
    ]
    do {
      try await rainSDKManager.initializePortal(
        portalSessionToken: sessionToken,
        networkConfigs: networkConfigs
      )
      self.portal = try rainSDKManager.portal
    } catch {
      throw LFRainSDKError.mapToAppError(error)
    }
    
    // TODO: - Remove - Temporarily register the PortalService for other methods
    do {
      try await base.registerPortal(sessionToken: sessionToken)
    } catch {
      log.error(error)
    }
  }
  
  public func createWallet(
  ) async throws -> String {
    try await base.createWallet()
  }
  
  public func send(
    to address: String,
    contractAddress: String?,
    amount: Double,
    conversionFactor: Int
  ) async throws -> String {
    try await base.send(to: address, contractAddress: contractAddress, amount: amount, conversionFactor: conversionFactor)
  }
  
  public func withdrawAsset(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    conversionFactor: Int,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> String {
    let addresses = WithdrawAssetAddresses(
      contractAddress: addresses.contractAddress,
      proxyAddress: addresses.proxyAddress,
      recipientAddress: addresses.recipientAddress,
      tokenAddress: addresses.tokenAddress
    )
    do {
      return try await rainSDKManager.withdrawCollateral(
        chainId: chainId,
        assetAddresses: addresses,
        amount: amount,
        decimals: conversionFactor,
        salt: signature.salt,
        signature: signature.signature,
        expiresAt: signature.expiresAt,
        nonce: nil
      )
    } catch {
      throw LFRainSDKError.mapToAppError(error)
    }
  }
  
  public func estimateTransferFee(
    to address: String,
    contractAddress: String?,
    amount: Double,
    conversionFactor: Int
  ) async throws -> Double {
    try await base.estimateTransferFee(to: address, contractAddress: contractAddress, amount: amount, conversionFactor: conversionFactor)
  }
  
  public func estimateWithdrawalFee(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    conversionFactor: Int,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> Double {
    let addresses = WithdrawAssetAddresses(
      contractAddress: addresses.contractAddress,
      proxyAddress: addresses.proxyAddress,
      recipientAddress: addresses.recipientAddress,
      tokenAddress: addresses.tokenAddress
    )
    do {
      return try await rainSDKManager.estimateWithdrawalFee(
        chainId: chainId,
        addresses: addresses,
        amount: amount,
        decimals: conversionFactor,
        salt: signature.salt,
        signature: signature.signature,
        expiresAt: signature.expiresAt
      )
    } catch {
      throw LFRainSDKError.mapToAppError(error)
    }
  }
  
  public func backup(
    backupMethod: BackupMethods,
    password: String?
  ) async throws -> (String, () async throws -> Void) {
    try await base.backup(backupMethod: backupMethod, password: password)
  }
  
  public func recover(
    backupMethod: BackupMethods,
    password: String?,
    cipherText: String
  ) async throws {
    try await base.recover(backupMethod: backupMethod, password: password, cipherText: cipherText)
  }
  
  public func refreshBalances(
  ) async throws -> (walletAddress: String?, balances: [String : Double]) {
    try await base.refreshBalances()
  }
  
  public func getSwapQuote(
    sellToken: String,
    buyToken: String,
    buyAmount: Double
  ) async throws -> Quote {
    try await base.getSwapQuote(sellToken: sellToken, buyToken: buyToken, buyAmount: buyAmount)
  }
  
  public func executeSwap(
    quote: Quote
  ) async throws -> String {
    try await base.executeSwap(quote: quote)
  }
  
  public func getWalletAddress(
  ) async -> String? {
    do {
      guard let portal else {
        return nil
      }
      
      // Currently, we only use eip55 address
      let addresses = try await portal.addresses
      return addresses[PortalNamespace.eip155] ?? nil
    } catch {
      return nil
    }
  }
  
  public func isWalletOnDevice(
  ) async -> Bool {
    do {
      guard let portal else {
        return false
      }
      return try await portal.isWalletOnDevice()
    } catch {
      return false
    }
  }
}
