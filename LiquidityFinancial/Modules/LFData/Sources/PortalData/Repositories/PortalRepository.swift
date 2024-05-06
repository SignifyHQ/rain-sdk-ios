import Foundation
import Services
import PortalDomain
import PortalSwift
import LFUtilities

public class PortalRepository: PortalRepositoryProtocol {
  private let portalStorage: PortalStorageProtocol
  private let portalAPI: PortalAPIProtocol
  private let portalService: PortalServiceProtocol

  public init(
    portalStorage: PortalStorageProtocol,
    portalAPI: PortalAPIProtocol,
    portalService: PortalServiceProtocol
  ) {
    self.portalStorage = portalStorage
    self.portalAPI = portalAPI
    self.portalService = portalService
  }
  
  public func refreshPortalSessionToken() async throws -> PortalSessionTokenEntity {
    try await portalAPI.refreshPortalSessionToken()
  }
  
  public func verifyAndUpdatePortalWalletAddress() async throws {
    try await portalAPI.verifyAndUpdatePortalWalletAddress()
  }
  
  public func registerPortal(portalToken: String) async throws {
    do {
      try await portalService.registerPortal(sessionToken: portalToken)
    } catch {
      guard let portalError = error as? LFPortalError, portalError == .expirationToken else {
        throw error
      }
      
      let token = try await tryRefreshPortalSessionToken()
      try await registerPortal(portalToken: token)
    }
  }
  
  public func createPortalWallet() async throws -> String {
    do {
      return try await portalService.createWallet()
    } catch {
      guard let portalError = error as? LFPortalError, portalError == .expirationToken else {
        throw error
      }
      
      _ = try await refreshPortalSessionToken()
      return try await createPortalWallet()
    }
  }
  
  public func backupWallet(backupMethod: BackupMethods, password: String?) async throws {
    do {
      let (cipherText, storageCallback) = try await portalService.backup(
        backupMethod: backupMethod,
        password: password
      )
      try await portalAPI.backupWallet(cipher: cipherText, method: backupMethod.rawValue)
      try await storageCallback()
    } catch {
      guard let portalError = error as? LFPortalError, portalError == .expirationToken else {
        throw error
      }
      
      _ = try await refreshPortalSessionToken()
      return try await backupWallet(backupMethod: backupMethod, password: password)
    }
  }
  
  public func estimateFee(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws -> Double {
    try await portalService.estimateFee(to: address, contractAddress: contractAddress, amount: amount)
  }
  
  public func send(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws {
    try await portalService.send(to: address, contractAddress: contractAddress, amount: amount)
  }  
    
  public func recoverWallet(backupMethod: BackupMethods, password: String?) async throws {
    do {
      let response = try await portalAPI.restoreWallet(method: backupMethod.rawValue)

      try await portalService.recover(
        backupMethod: backupMethod,
        password: password,
        cipherText: response.cipherText
      )
    } catch {
      guard let portalError = error as? LFPortalError, portalError == .expirationToken else {
        throw error
      }
      
      _ = try await refreshPortalSessionToken()
      try await recoverWallet(backupMethod: backupMethod, password: password)
    }
  }
  
  public func refreshBalances() async throws {
    let balances = try await portalService.refreshBalances()
    portalStorage.update(walletAddress: balances.walletAddress, balances: balances.balances)
  }
  
  public func getPortalBackupMethods() async throws -> PortalBackupMethodsEntity {
    try await portalAPI.getBackupMethods()
  }

}

// MARK: - Private Functions
private extension PortalRepository {
  func tryRefreshPortalSessionToken() async throws -> String {
    do {
      let token = try await portalAPI.refreshPortalSessionToken()
      UserDefaults.portalSessionToken = token.clientSessionToken
      return token.clientSessionToken
    } catch {
      throw error
    }
  }
}
