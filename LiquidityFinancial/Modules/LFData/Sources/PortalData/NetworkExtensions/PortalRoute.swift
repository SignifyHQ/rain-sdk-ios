import Foundation
import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities

public enum PortalRoute {
  case backupWallet(cipher: String, method: String)
  case restoreWallet(method: String)
  case refreshPortalSessionToken
  case verifyAndUpdatePortalWallet
  case backupMethods
}

extension PortalRoute: LFRoute {
  public var path: String {
    switch self {
    case .backupWallet, .restoreWallet:
      return "/v1/portal/backup"
    case .refreshPortalSessionToken:
      return "/v1/portal/clients/refresh-session"
    case .verifyAndUpdatePortalWallet:
      return "/v1/portal/clients/verify-and-update-wallet-address"
    case .backupMethods:
      return "/v1/portal/backup/methods"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .backupWallet,
        .verifyAndUpdatePortalWallet:
      return .POST
    case .restoreWallet,
        .refreshPortalSessionToken,
        .backupMethods:
      return .GET
    }
  }
  
  public var httpHeaders: HttpHeaders {
    var base = [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "ld-device-id": LFUtilities.deviceId
    ]
    base["Authorization"] = self.needAuthorizationKey
    return base
  }
  
  public var parameters: Parameters? {
    switch self {
    case .refreshPortalSessionToken,
        .verifyAndUpdatePortalWallet,
        .backupMethods:
      return nil
    case .backupWallet(let cipher, let method):
      return [
        "backupMethod": method,
        "cipherText": cipher
      ]
    case .restoreWallet(let method):
      return [
        "backupMethod": method
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .backupWallet:
      return .json
    case .restoreWallet:
      return .url
    case .refreshPortalSessionToken,
        .verifyAndUpdatePortalWallet,
        .backupMethods:
      return nil
    }
  }
}
