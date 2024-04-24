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
  
  public func backupWallet(cipher: String, method: String) async throws {
    try await portalAPI.backupWallet(cipher: cipher, method: method)
  }
  
  public func restoreWallet(method: String) async throws -> WalletRestoreEntitiy {
    try await portalAPI.restoreWallet(method: method)
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
  
  public func backupPortalWallet(backupMethod: BackupMethods, backupConfigs: BackupConfigs?) async throws -> String {
    do {
      return try await portalService.backup(
        backupMethod: backupMethod,
        backupConfigs: backupConfigs
      )
    } catch {
      guard let portalError = error as? LFPortalError, portalError == .expirationToken else {
        throw error
      }
      
      _ = try await refreshPortalSessionToken()
      return try await backupPortalWallet(backupMethod: backupMethod, backupConfigs: backupConfigs)
    }
  }
  
  public func refreshBalances() async throws {
    let balances = try await portalService.getBalances()
    portalStorage.store(balances: balances)
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
