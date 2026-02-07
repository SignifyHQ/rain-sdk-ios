import Foundation

/// Errors that can occur in the Rain SDK
/// Structured with error codes for easy identification and debugging
public enum RainSDKError: Error, LocalizedError, Equatable {
  // MARK: - 1xx: Initialization Errors
  
  /// RAIN_101: Business methods were called before initialize() was successfully completed
  case sdkNotInitialized
  
  /// RAIN_102: The provided RPC URL format or Chain ID is invalid or unsupported
  case invalidConfig(chainId: Int, rpcUrl: String)
  
  // MARK: - 2xx: Authentication Errors
  
  /// RAIN_201: The Portal Session Token has expired or is no longer valid
  case tokenExpired(token: String)
  
  /// RAIN_202: Invalid Rain API Key or insufficient permissions for the requested operation
  case unauthorized
  
  // MARK: - 3xx: Network Errors
  
  /// RAIN_301: Connectivity issues preventing communication with APIs or Blockchain nodes
  case networkError(underlying: Error)
  
  // MARK: - 4xx: User Action Errors
  
  /// RAIN_401: The user manually cancelled the signature request within the wallet UI
  case userRejected
  
  /// RAIN_402: The wallet balance is too low for the withdrawal amount or the required gas fees
  case insufficientFunds(required: String, available: String)
  
  // MARK: - 5xx: Internal / Provider Errors
  
  /// RAIN_501: An unhandled error occurred within the Portal SDK or the external wallet provider
  case providerError(underlying: Error)
  
  /// RAIN_502: Error processing EIP-712 data or internal state management failure
  case internalLogicError(details: String)
  
  // MARK: - Error Code
  
  /// The error code (e.g., "RAIN_101")
  public var errorCode: String {
    switch self {
    case .sdkNotInitialized:
      return "RAIN_101"
    case .invalidConfig:
      return "RAIN_102"
    case .tokenExpired:
      return "RAIN_201"
    case .unauthorized:
      return "RAIN_202"
    case .networkError:
      return "RAIN_301"
    case .userRejected:
      return "RAIN_401"
    case .insufficientFunds:
      return "RAIN_402"
    case .providerError:
      return "RAIN_501"
    case .internalLogicError:
      return "RAIN_502"
    }
  }
  
  // MARK: - LocalizedError
  
  public var errorDescription: String? {
    switch self {
    case .sdkNotInitialized:
      return "[\(errorCode)] Business methods were called before initialize() was successfully completed."
    case .invalidConfig(let chainId, let rpcUrl):
      return "[\(errorCode)] The provided RPC URL format or Chain ID is invalid or unsupported. Chain ID: \(chainId). RPC URL: \(rpcUrl)."
    case .tokenExpired(let token):
      return "[\(errorCode)] The Portal Session Token has expired or is no longer valid. Token: \(token.prefix(10))..."
    case .unauthorized:
      return "[\(errorCode)] Invalid Rain API Key or insufficient permissions for the requested operation."
    case .networkError(let underlying):
      return "[\(errorCode)] Connectivity issues preventing communication with APIs or Blockchain nodes. \(underlying.localizedDescription)"
    case .userRejected:
      return "[\(errorCode)] The user manually cancelled the signature request within the wallet UI."
    case .insufficientFunds(let required, let available):
      return "[\(errorCode)] The wallet balance is too low for the withdrawal amount or the required gas fees. Required: \(required). Available: \(available)."
    case .providerError(let underlying):
      return "[\(errorCode)] An unhandled error occurred within the Portal SDK or the external wallet provider. \(underlying.localizedDescription)"
    case .internalLogicError(let details):
      return "[\(errorCode)] Error processing EIP-712 data or internal state management failure. Details: \(details)"
    }
  }
}
//
extension RainSDKError {
  public static func == (lhs: RainSDKError, rhs: RainSDKError) -> Bool {
    lhs.errorCode == rhs.errorCode
  }
}
