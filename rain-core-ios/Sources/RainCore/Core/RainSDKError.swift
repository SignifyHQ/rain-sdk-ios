import Foundation

/// Errors that can occur in the Rain SDK
/// Structured with error codes for easy identification and debugging
public enum RainSDKError: Error, LocalizedError, Equatable {
  // MARK: - 1xx: Initialization Errors
  
  /// RAIN_101: Business methods were called before initialize() was successfully completed
  case sdkNotInitialized
  
  /// RAIN_102: Invalid SDK configuration or parameter — `details` says what was wrong.
  case invalidConfig(details: String)

  /// RAIN_102: No provider registered for the requested id / capability.
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

  // The four cases below are token-transfer failures callers need to tell apart in the UI. They
  // carry their own payloads but deliberately reuse existing error codes: the code map is a
  // published contract host apps switch on, so a new code would fork it.

  /// RAIN_402: The wallet holds less of the token than the transfer asks for — the shortfall is
  /// in the token itself, not in the chain's native currency.
  case insufficientTokenBalance(requested: String, available: String, token: String)

  /// RAIN_402: The wallet has no account for this token, so there is nothing to send. On Solana a
  /// balance lives in a per-mint token account that exists only once the wallet has received it.
  case tokenAccountNotFound(walletAddress: String, token: String)

  /// RAIN_102: No token exists at this address on this chain (wrong address, or wrong cluster).
  case tokenNotFound(token: String, chainId: Int)

  /// RAIN_102: The recipient address cannot receive this transfer — see `reason`.
  case invalidRecipient(address: String, reason: String)

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
    case .invalidConfig, .providerNotRegistered, .tokenNotFound, .invalidRecipient:
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
    case .insufficientFunds, .insufficientTokenBalance, .tokenAccountNotFound:
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
    case .invalidConfig(let details):
      return "[\(errorCode)] \(details)"
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
    case .insufficientTokenBalance(let requested, let available, let token):
      return "[\(errorCode)] Insufficient balance for \(token): requested \(requested), available \(available)."
    case .tokenAccountNotFound(let walletAddress, let token):
      return "[\(errorCode)] Wallet \(walletAddress) holds no account for token \(token)."
    case .tokenNotFound(let token, let chainId):
      return "[\(errorCode)] No token found at \(token) on chainId=\(chainId)."
    case .invalidRecipient(let address, let reason):
      return "[\(errorCode)] Invalid recipient \(address): \(reason)."
    case .providerError(let underlying):
      return "[\(errorCode)] An unhandled error occurred within the wallet provider. \(underlying.localizedDescription)"
    case .internalLogicError(let details):
      return "[\(errorCode)] Error processing EIP-712 data or internal state management failure. Details: \(details)"
    }
  }
}
extension RainSDKError {
  /// Stable per-case name, payload-insensitive. Several cases share an errorCode, so equality
  /// needs this to keep e.g. .insufficientFunds and .tokenAccountNotFound distinct.
  internal var caseIdentifier: String {
    switch self {
    case .sdkNotInitialized: return "sdkNotInitialized"
    case .invalidConfig: return "invalidConfig"
    case .providerNotRegistered: return "providerNotRegistered"
    case .invalidRpcUrl: return "invalidRpcUrl"
    case .rainApiNotConfigured: return "rainApiNotConfigured"
    case .tokenExpired: return "tokenExpired"
    case .unauthorized: return "unauthorized"
    case .networkError: return "networkError"
    case .apiError: return "apiError"
    case .signatureNotReady: return "signatureNotReady"
    case .noCollateralContracts: return "noCollateralContracts"
    case .userRejected: return "userRejected"
    case .insufficientFunds: return "insufficientFunds"
    case .transactionSimulationFailed: return "transactionSimulationFailed"
    case .walletUnavailable: return "walletUnavailable"
    case .withdrawalRevertedByNetwork: return "withdrawalRevertedByNetwork"
    case .invalidAmount: return "invalidAmount"
    case .walletNotAuthorized: return "walletNotAuthorized"
    case .insufficientTokenBalance: return "insufficientTokenBalance"
    case .tokenAccountNotFound: return "tokenAccountNotFound"
    case .tokenNotFound: return "tokenNotFound"
    case .invalidRecipient: return "invalidRecipient"
    case .providerError: return "providerError"
    case .internalLogicError: return "internalLogicError"
    }
  }

  /// Same enum case (payload-insensitive) and same published error code.
  public static func == (lhs: RainSDKError, rhs: RainSDKError) -> Bool {
    lhs.errorCode == rhs.errorCode && lhs.caseIdentifier == rhs.caseIdentifier
  }
}
