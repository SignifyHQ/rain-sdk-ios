import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: PortalAPIProtocol where R == PortalRoute {
  
  public func backupWallet(cipher: String, method: String) async throws {
    try await requestNoResponse(
      PortalRoute.backupWallet(cipher: cipher, method: method),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func restoreWallet(method: String) async throws -> APIWalletRestore {
    try await request(
      PortalRoute.restoreWallet(method: method),
      target: APIWalletRestore.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func refreshPortalSessionToken() async throws -> APIPortalSessionToken {
    try await request(
      PortalRoute.refreshPortalSessionToken,
      target: APIPortalSessionToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func verifyAndUpdatePortalWalletAddress() async throws {
    try await requestNoResponse(
      PortalRoute.verifyAndUpdatePortalWallet,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getBackupMethods() async throws -> APIPortalBackupMethods {
    try await request(
      PortalRoute.backupMethods,
      target: APIPortalBackupMethods.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
