import Foundation
import PortalSwift
import LFLocalizable

public enum LFPortalError: LocalizedError {
  case dataUnavailable
  case portalInstanceUnavailable
  case sessionTokenUnavailable
  case sessionExpired
  case walletAlreadyExists
  case iCloudAccountUnavailable
  case cipherBlockCreationFailed
  case unexpected
  case walletMissing
  case decryptFailed
  case customError(message: String)
  
  public var errorDescription: String? {
    switch self {
    case .dataUnavailable:
      "Data unavailable"
    case .portalInstanceUnavailable:
      "Portal instance unavailable"
    case .sessionTokenUnavailable:
      "Portal session token unavailable"
    case .sessionExpired:
      "Portal session expired"
    case .walletAlreadyExists:
      "Walllet already exists"
    case .iCloudAccountUnavailable:
      "iCloud account unavailable. Please make sure you are signed in to iCloud on your device"
    case .cipherBlockCreationFailed:
      "Cipper block creation failed"
    case .unexpected:
      "Unexpected error"
    case .walletMissing:
      "Wallet missing"
    case .decryptFailed:
      "Decrypt failed"
    case .customError(let message):
      message
    }
  }
}

extension LFPortalError: Equatable {
  public static func == (lhs: LFPortalError, rhs: LFPortalError) -> Bool {
    switch (lhs, rhs) {
    case (.dataUnavailable, .dataUnavailable),
      (.portalInstanceUnavailable, .portalInstanceUnavailable),
      (.sessionExpired, .sessionExpired),
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
    case .unauthorized:
      return .sessionExpired
    case .clientError(let message, _):
      if message.contains(PortalErrorMessage.sessionExpired) || message.contains("401") {
        return .sessionExpired
      }
      return LFPortalError.customError(message: message)
    case .internalServerError(let message, _),
        .redirectError(let message):
      return .customError(message: message)
    default:
      return .customError(message: portalRequestsError.localizedDescription)
    }
  }
  
  public static func handlePortalError(error: Error?) -> LFPortalError {
    // TODO: - Will need to revise and update the error handling, it's a mess :(
    
    guard let error else {
      return LFPortalError.unexpected
    }
    
    guard let portalMpcError = error as? PortalMpcError else {
      if let iCloudError = error as? ICloudStorage.ICloudStorageError,
         case .unableToReadFile = iCloudError {
        // Different iCloud is used, no access to the backup share
        return LFPortalError.cipherBlockCreationFailed
      }
      
      return LFPortalError.handlePortalRequestError(error: error)
    }

    if portalMpcError.id == "DECRYPT_FAILED" {
      return .decryptFailed
    }
    
    switch portalMpcError.code {
    case 320:
      return .sessionExpired
    case PortalErrorCodes.INVALID_API_KEY.rawValue:
      return .sessionExpired
    case PortalErrorCodes.BAD_REQUEST.rawValue:
      return portalMpcError.message?.lowercased().contains(PortalErrorMessage.walletAlreadyExists) == true
      ? .walletAlreadyExists
      : .customError(message: portalMpcError.message ?? PortalErrorMessage.unexpectedError)
    case PortalErrorCodes.FAILED_TO_DECRYPT_CIPHER.rawValue:
      let message = portalMpcError.message?.lowercased().contains(PortalErrorMessage.authenticationFailed) == true
      ? L10N.Common.BackupByPinCode.WrongCode.error
      : portalMpcError.message
      return .customError(message: message ?? PortalErrorMessage.unexpectedError)
    case PortalErrorCodes.FAILED_TO_CREATE_CIPHER_BLOCK.rawValue:
      return .cipherBlockCreationFailed
    case PortalErrorCodes.NODE_RPC_ERROR.rawValue:
      return .customError(message: L10N.Common.MoveCryptoInput.NotEnoughCrypto.description)
    default:
      return .customError(message: portalMpcError.message ?? PortalErrorMessage.unexpectedError)
    }
  }
}

// MARK: - Types
extension LFPortalError {
  enum PortalErrorMessage {
    static let walletAlreadyExists = "wallet already exists"
    static let sessionExpired = "SESSION_EXPIRED"
    static let authenticationFailed = "authentication failed"
    static let unexpectedError = "unexpected error"
  }
}
