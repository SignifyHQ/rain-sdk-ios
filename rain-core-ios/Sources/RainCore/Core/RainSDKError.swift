import Foundation

/// Errors that can occur in the Rain SDK
/// Structured with error codes for easy identification and debugging
public enum RainSDKError: Error, LocalizedError, Equatable {
  // MARK: - 1xx: Initialization Errors
  
  /// RAIN_101: Business methods were called before initialize() was successfully completed
  case sdkNotInitialized
  
  /// RAIN_102: The provided RPC URL format or Chain ID is invalid or unsupported
  case invalidConfig(chainId: Int, rpcUrl: String)

  /// RAIN_102: No provider registered for the requested id / capability (parity with
  /// Android's `RainError.InvalidConfig` message for the same states)
  case providerNotRegistered(details: String)

  /// RAIN_103: An RPC URL could not be parsed as a valid URL (no chain ID context)
  case invalidRpcUrl(String)

  /// RAIN_104: A Rain API method was called before an Api-Key and userId were supplied
  case rainApiNotConfigured

  // MARK: - 2xx: Authentication Errors

  /// RAIN_201: The wallet provider session token has expired or is no longer valid
  case tokenExpired

  /// RAIN_202: Invalid Rain API Key or insufficient permissions for the requested operation
  case unauthorized

  // MARK: - 3xx: Network Errors

  /// RAIN_301: Connectivity issues preventing communication with APIs or Blockchain nodes
  case networkError(underlying: Error)

  /// RAIN_302: The Rain API returned a non-success HTTP status (other than 401/403 → `.unauthorized`)
  case apiError(statusCode: Int, message: String?)

  /// RAIN_303: The withdrawal admin signature is not ready yet; retry after `retryAfter` seconds
  case signatureNotReady(status: String, retryAfter: Int?)

  /// RAIN_304: The contracts endpoint returned no collateral contracts for the configured user
  case noCollateralContracts
  
  // MARK: - 4xx: User Action Errors
  
  /// RAIN_401: The user manually cancelled the signature request within the wallet UI
  case userRejected
  
  /// RAIN_402: The wallet balance is too low for the withdrawal amount or the required gas fees
  case insufficientFunds(required: String, available: String)
  
  /// RAIN_403: Transaction simulation (preflight) failed before submission, e.g. a contract revert surfaced by `eth_call`
  case transactionSimulationFailed(underlying: Error)

  /// RAIN_404: No wallet address available from the wallet provider (e.g. user has not connected or created a wallet)
  case walletUnavailable

  /// RAIN_405: Withdrawal reverted because the same amount was withdrawn in a short period; backend returned an already-used withdrawal signature
  case withdrawalRevertedByNetwork

  /// RAIN_406: The amount is invalid for the token — more decimal places than the token supports, or negative/unrepresentable
  case invalidAmount(amount: String, reason: String)

  /// RAIN_407: The signing wallet is not an admin of the collateral contract, so `withdrawAsset`
  /// would reject its signature on-chain with `InvalidSignature()`
  case walletNotAuthorized(walletAddress: String, proxyAddress: String)

  // MARK: - 5xx: Internal / Provider Errors
  
  /// RAIN_501: An unhandled error occurred within the wallet provider
  case providerError(underlying: Error)
  
  /// RAIN_502: Error processing EIP-712 data or internal state management failure
  case internalLogicError(details: String)
  
  // MARK: - Error Code
  
  /// The error code (e.g., "RAIN_101")
  public var errorCode: String {
    switch self {
    case .sdkNotInitialized:
      return "RAIN_101"
    case .invalidConfig, .providerNotRegistered:
      return "RAIN_102"
    case .invalidRpcUrl:
      return "RAIN_103"
    case .rainApiNotConfigured:
      return "RAIN_104"
    case .tokenExpired:
      return "RAIN_201"
    case .unauthorized:
      return "RAIN_202"
    case .networkError:
      return "RAIN_301"
    case .apiError:
      return "RAIN_302"
    case .signatureNotReady:
      return "RAIN_303"
    case .noCollateralContracts:
      return "RAIN_304"
    case .userRejected:
      return "RAIN_401"
    case .insufficientFunds:
      return "RAIN_402"
    case .transactionSimulationFailed:
      return "RAIN_403"
    case .walletUnavailable:
      return "RAIN_404"
    case .withdrawalRevertedByNetwork:
      return "RAIN_405"
    case .invalidAmount:
      return "RAIN_406"
    case .walletNotAuthorized:
      return "RAIN_407"
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
    case .providerNotRegistered(let details):
      return "[\(errorCode)] \(details)"
    case .invalidRpcUrl(let rpcUrl):
      return "[\(errorCode)] The provided RPC URL could not be parsed. RPC URL: \(rpcUrl)."
    case .rainApiNotConfigured:
      return "[\(errorCode)] Rain API is not configured — call configureRainApi(apiKey:userId:) first."
    case .tokenExpired:
      return "[\(errorCode)] The wallet provider session token has expired or is no longer valid."
    case .unauthorized:
      return "[\(errorCode)] Invalid Rain API Key or insufficient permissions for the requested operation."
    case .networkError(let underlying):
      return "[\(errorCode)] Connectivity issues preventing communication with APIs or Blockchain nodes. \(underlying.localizedDescription)"
    case .apiError(let statusCode, let message):
      return "[\(errorCode)] Rain API error \(statusCode)\(message.map { ": \($0)" } ?? "")."
    case .signatureNotReady(let status, let retryAfter):
      return "[\(errorCode)] Withdrawal signature not ready: status=\(status)\(retryAfter.map { " (retry after \($0)s)" } ?? "")."
    case .noCollateralContracts:
      return "[\(errorCode)] No collateral contracts returned for user."
    case .userRejected:
      return "[\(errorCode)] The user manually cancelled the signature request within the wallet UI."
    case .insufficientFunds(let required, let available):
      return "[\(errorCode)] The wallet balance is too low for the withdrawal amount or the required gas fees. Required: \(required). Available: \(available)."
    case .transactionSimulationFailed(let underlying):
      return "[\(errorCode)] Transaction simulation failed before submission. \(underlying.localizedDescription)"
    case .walletUnavailable:
      return "[\(errorCode)] No wallet address available from the wallet provider."
    case .withdrawalRevertedByNetwork:
      return "[\(errorCode)] Execution reverted by the network. Please try again in a few minutes."
    case .invalidAmount(let amount, let reason):
      return "[\(errorCode)] Invalid amount (\(amount)): \(reason)."
    case .walletNotAuthorized(let walletAddress, let proxyAddress):
      return "[\(errorCode)] Wallet \(walletAddress) is not an admin of collateral contract \(proxyAddress)."
    case .providerError(let underlying):
      return "[\(errorCode)] An unhandled error occurred within the wallet provider. \(underlying.localizedDescription)"
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
