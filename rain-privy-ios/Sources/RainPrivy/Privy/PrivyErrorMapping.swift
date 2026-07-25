import Foundation
import PrivySDK
import RainCore

/// Registers Privy vendor-error mapping with `RainCore`'s extensible error mapper, so Privy errors
/// classify into `RainSDKError` cases (`.userRejected`, `.insufficientFunds`, `.tokenExpired`, …)
/// without RainCore importing PrivySDK.
enum PrivyErrorMapping {
  nonisolated(unsafe) private static var registered = false
  private static let lock = NSLock()

  /// Registers the mapper exactly once per process.
  static func registerOnce() {
    lock.lock(); defer { lock.unlock() }
    guard !registered else { return }
    registered = true
    RainSDKError.registerErrorMapper(map)
  }

  /// Returns a classified `RainSDKError` for a Privy vendor error, or `nil` for anything this
  /// adapter doesn't own (so core's built-in fallbacks still run).
  private static func map(_ error: Error) -> RainSDKError? {
    guard let privyError = error as? PrivyError else { return nil }
    switch privyError.errorCode {
    case .authenticationFailure(let reason):
      return mapAuthenticationFailure(reason, error: privyError)
    case .embeddedWalletFailure(let reason):
      return mapEmbeddedWalletFailure(reason, error: privyError)
    case .initializationFailed:
      return .providerError(underlying: privyError)
    @unknown default:
      return .providerError(underlying: privyError)
    }
  }

  private static func mapAuthenticationFailure(
    _ reason: PrivyErrorCode.AuthenticationFailureReason,
    error: PrivyError
  ) -> RainSDKError {
    switch reason {
    case .notLoggedIn, .invalidJwt:
      return .tokenExpired
    case .passkeyUserCancelled:
      return .userRejected
    case .failureDuringAuthentication(let underlying):
      // May wrap ASAuthorizationError.canceled / a network error; recurse so it classifies.
      return RainSDKError.from(underlying: underlying)
    default:
      return .providerError(underlying: error)
    }
  }

  private static func mapEmbeddedWalletFailure(
    _ reason: PrivyErrorCode.EmbeddedWalletFailureReason,
    error: PrivyError
  ) -> RainSDKError {
    switch reason {
    case .noWalletAvailable, .creationFailed:
      return .walletUnavailable
    case .unsupportedChain, .rpcUrlNotFound:
      // A misconfiguration rather than a provider failure at runtime.
      return .internalLogicError(details: "Privy: \(error.localizedDescription)")
    // The EIP-1193 and Solana send paths surface node / user-facing failures as these
    // message-carrying cases; classify by message.
    case .jsonRpcError(let message),
         .signerError(let message),
         .transactionError(let message),
         .invalidSolanaTransaction(let message):
      return classify(message: message, fallback: error)
    case .invalidRpcParams(_, let description):
      return classify(message: description, fallback: error)
    case .iframeError(_, let message):
      return classify(message: message, fallback: error)
    default:
      return .providerError(underlying: error)
    }
  }

  /// Keyword classification for Privy's free-text RPC error messages.
  private static func classify(message: String, fallback: PrivyError) -> RainSDKError {
    let lower = message.lowercased()
    if lower.contains("reject") || lower.contains("denied") || lower.contains("cancel") {
      return .userRejected
    }
    if lower.contains("insufficient") {
      return .insufficientFunds(required: "", available: "")
    }
    return .providerError(underlying: fallback)
  }
}
