import Foundation
import RainSDK

/// App-level representation of Rain SDK errors with user-friendly messages.
/// Maps from `RainSDKError` (SDK) to display strings.
public enum LFRainSDKError: LocalizedError, Equatable {
  case sdkNotInitialized
  case invalidConfig
  case tokenExpired
  case unauthorized
  case networkError
  case userRejected
  case insufficientFunds(required: String, available: String)
  case walletUnavailable
  case providerError
  case internalLogicError

  public var errorDescription: String? {
    switch self {
    case .sdkNotInitialized:
      return "Please try again. If this continues, restart the app."
    case .invalidConfig:
      return "Network configuration is invalid. Please check your settings."
    case .tokenExpired:
      return "Your session has expired. Please sign in again."
    case .unauthorized:
      return "Something went wrong with permissions. Please try again or sign in again."
    case .networkError:
      return "Connection problem. Please check your internet and try again."
    case .userRejected:
      return "You cancelled the request."
    case .insufficientFunds(let required, let available):
      return "Not enough balance. Need \(required), you have \(available)."
    case .walletUnavailable:
      return "No wallet available. Please connect or create a wallet."
    case .providerError:
      return "The wallet encountered an issue. Please try again."
    case .internalLogicError:
      return "Something went wrong. Please try again."
    }
  }
}

// MARK: - Map from RainSDKError
extension LFRainSDKError {
  /// Maps `RainSDKError` (or any `Error`) to a user-facing `LFRainSDKError`.
  public static func from(_ error: Error) -> LFRainSDKError {
    guard let sdkError = error as? RainSDKError else {
      return .internalLogicError
    }
    switch sdkError {
    case .sdkNotInitialized:
      return .sdkNotInitialized
    case .invalidConfig:
      return .invalidConfig
    case .tokenExpired:
      return .tokenExpired
    case .unauthorized:
      return .unauthorized
    case .networkError:
      return .networkError
    case .userRejected:
      return .userRejected
    case .insufficientFunds(let required, let available):
      return .insufficientFunds(required: required, available: available)
    case .walletUnavailable:
      return .walletUnavailable
    case .providerError:
      return .providerError
    case .internalLogicError:
      return .internalLogicError
    }
  }

  /// Maps SDK error to an app error. Returns `LFPortalError` for `providerError` so callers that use `LFPortalError` still work; otherwise returns `LFRainSDKError`.
  public static func mapToAppError(_ error: Error) -> Error {
    guard let sdkError = error as? RainSDKError else {
      return LFRainSDKError.from(error)
    }
    
    // TODO: Consider removing this; keep the logic for now.
    if case .providerError(let portalError) = sdkError {
      return LFPortalError.handlePortalError(error: portalError)
    }
    
    return LFRainSDKError.from(error)
  }
}
