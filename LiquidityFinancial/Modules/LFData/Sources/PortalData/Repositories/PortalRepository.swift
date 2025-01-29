import Foundation
import Services
import PortalDomain
import PortalSwift
import LFUtilities

public class PortalRepository: PortalRepositoryProtocol {
  private let portalStorage: PortalStorageProtocol
  private let portalAPI: PortalAPIProtocol
  private let portalService: PortalServiceProtocol
  private let maxRetryAttempts = 3

  public init(
    portalStorage: PortalStorageProtocol,
    portalAPI: PortalAPIProtocol,
    portalService: PortalServiceProtocol
  ) {
    self.portalStorage = portalStorage
    self.portalAPI = portalAPI
    self.portalService = portalService
  }
  
  public func verifyAndUpdatePortalWalletAddress() async throws {
    try await portalAPI.verifyAndUpdatePortalWalletAddress()
  }
  
  public func registerPortal(
    portalToken: String
  ) async throws {
    try await performWithSessionRefresh { [self] in try await portalService.registerPortal(sessionToken: portalToken) }
  }
  
  public func createPortalWallet() async throws -> String {
    return try await performWithSessionRefresh { [self] in try await portalService.createWallet() }
  }
  
  public func backupWallet(
    backupMethod: BackupMethods,
    password: String?
  ) async throws {
    try await performWithSessionRefresh { [self] in
      let (cipherText, storageCallback) = try await portalService.backup(
        backupMethod: backupMethod,
        password: password
      )
      
      try await portalAPI.backupWallet(cipher: cipherText, method: backupMethod.rawValue)
      try await storageCallback()
    }
  }
  
  public func estimateTransferFee(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws -> Double {
    guard let token = portalStorage.token(with: contractAddress) else {
      throw LFPortalError.dataUnavailable
    }
    
    return try await performWithSessionRefresh { [self] in
      try await portalService.estimateTransferFee(
        to: address,
        contractAddress: contractAddress,
        amount: amount,
        conversionFactor: token.conversionFactor
      )
    }
  }
  
  public func estimateWithdrawalFee(
    addresses: Services.PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: Services.PortalService.WithdrawAssetSignature
  ) async throws -> Double {
    guard let token = portalStorage.token(with: addresses.tokenAddress) else {
      throw LFPortalError.dataUnavailable
    }
    
    return try await performWithSessionRefresh { [self] in
      try await portalService.estimateWithdrawalFee(
        addresses: addresses,
        amount: amount,
        conversionFactor: token.conversionFactor,
        signature: signature
      )
    }
  }
  
  public func send(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws -> String {
    guard let token = portalStorage.token(with: contractAddress) else {
      throw LFPortalError.dataUnavailable
    }
    
    return try await performWithSessionRefresh { [self] in
      try await portalService.send(
        to: address,
        contractAddress: contractAddress,
        amount: amount,
        conversionFactor: token.conversionFactor
      )
    }
  }
  
  public func withdrawAsset(
    addresses: PortalService.WithdrawAssetAddresses,
    amount: Double,
    signature: PortalService.WithdrawAssetSignature
  ) async throws -> String {
    guard let token = portalStorage.token(with: addresses.tokenAddress) else {
      throw LFPortalError.dataUnavailable
    }
    
    return try await performWithSessionRefresh { [self] in
      try await portalService.withdrawAsset(
        addresses: addresses,
        amount: amount,
        conversionFactor: token.conversionFactor,
        signature: signature
      )
    }
  }
  
  public func recoverWallet(
    backupMethod: BackupMethods,
    password: String?
  ) async throws {
    try await performWithSessionRefresh { [self] in
      let response = try await portalAPI.restoreWallet(method: backupMethod.rawValue)
      
      try await portalService.recover(
        backupMethod: backupMethod,
        password: password,
        cipherText: response.cipherText
      )
    }
  }
  
  public func refreshBalances() async throws {
    try await performWithSessionRefresh { [self] in
      let balances = try await portalService.refreshBalances()
      
      portalStorage.update(
        walletAddress: balances.walletAddress,
        balances: balances.balances
      )
    }
  }
  
  public func getPortalBackupMethods() async throws -> PortalBackupMethodsEntity {
    return try await portalAPI.getBackupMethods()
  }
  
  public var chainId: String {
    portalService.chainId.description
  }
  
  // MARK: - Private Functions
  private func tryRefreshPortalSessionToken() async throws {
    let token = try await portalAPI.refreshPortalSessionToken().clientSessionToken
    
    try await registerPortal(portalToken: token)
    UserDefaults.portalSessionToken = token
  }
  
  private func performWithSessionRefresh<T>(
    retryCount: Int = 0,
    _ action: @escaping () async throws -> T
  ) async throws -> T {
    log.info("Refreshing Portal session. Attempt \(retryCount) of \(maxRetryAttempts)")
    
    do {
      let result = try await action()
      log.info("Portal session refresh success. Attempt \(retryCount) of \(maxRetryAttempts)")
      
      return result
    } catch let error as LFPortalError where error == .sessionExpired {
      guard retryCount < maxRetryAttempts
      else {
        log.error("Portal session refresh failed. Max number of retries (\(maxRetryAttempts)) reached")
        
        throw error
      }
      
      try await tryRefreshPortalSessionToken()
      return try await performWithSessionRefresh(retryCount: retryCount + 1, action)
    } catch {
      log.error("Portal session refresh failed with error: \(error). Attempt \(retryCount) of \(maxRetryAttempts)")
      
      throw error
    }
  }
}
