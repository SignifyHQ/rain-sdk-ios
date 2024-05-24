import Foundation
import PortalSwift

public enum LFPortalError: Error {
  case dataUnavailable
  case portalInstanceUnavailable
  case expirationToken
  case walletAlreadyExists
  case iCloudAccountUnavailable
  case unexpected
  case walletMissing
  case customError(message: String)
}

extension LFPortalError: Equatable {
  public static func == (lhs: LFPortalError, rhs: LFPortalError) -> Bool {
    switch (lhs, rhs) {
    case (.dataUnavailable, .dataUnavailable),
      (.portalInstanceUnavailable, .portalInstanceUnavailable),
      (.expirationToken, .expirationToken),
      (.walletAlreadyExists, .walletAlreadyExists),
      (.iCloudAccountUnavailable, .iCloudAccountUnavailable),
      (.unexpected, .unexpected),
      (.walletMissing, .walletMissing):
      return true
    case (.customError(let lhsMessage), .customError(let rhsMessage)):
      return lhsMessage == rhsMessage
    default:
      return false
    }
  }
}

// MARK: - Functions
extension LFPortalError {
  private static func handlePortalRequestError(error: Error) -> LFPortalError {
    guard let portalRequestsError = error as? PortalRequestsError else {
      return LFPortalError.customError(message: error.localizedDescription)
    }
    
    switch portalRequestsError {
    case .clientError(let message):
      if message.contains(PortalErrorMessage.sessionExpired) {
        return LFPortalError.expirationToken
      }
      return LFPortalError.customError(message: message)
    case .internalServerError(let message),
        .redirectError(let message):
      return LFPortalError.customError(message: message)
    default:
      return LFPortalError.customError(message: portalRequestsError.localizedDescription)
    }
  }
  
  public static func handlePortalError(error: Error?) -> LFPortalError {
    guard let error else {
      return LFPortalError.unexpected
    }
    
    guard let portalMpcError = error as? PortalMpcError else {
      return LFPortalError.handlePortalRequestError(error: error)
    }
    
    switch portalMpcError.code {
    case 320:
      return LFPortalError.expirationToken
    case PortalErrorCodes.INVALID_API_KEY.rawValue:
      return LFPortalError.expirationToken
    case PortalErrorCodes.BAD_REQUEST.rawValue:
      return portalMpcError.message.lowercased().contains(PortalErrorMessage.walletAlreadyExists)
      ? LFPortalError.walletAlreadyExists
      : LFPortalError.customError(message: portalMpcError.message)
    default:
      return LFPortalError.customError(message: portalMpcError.message)
    }
  }
}

// MARK: - Types
extension LFPortalError {
  enum PortalErrorMessage {
    static let walletAlreadyExists = "wallet already exists"
    static let sessionExpired = "SESSION_EXPIRED"
  }
}
