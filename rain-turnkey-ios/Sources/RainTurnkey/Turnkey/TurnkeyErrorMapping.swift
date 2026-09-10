import AuthenticationServices
import Foundation
import TurnkeyHttp
import TurnkeySwift
import RainCore

/// Registers Turnkey vendor-error mapping with `RainCore`'s extensible error mapper, so Turnkey
/// errors classify into `RainSDKError` cases without RainCore importing the Turnkey SDK.
/// Mirrors `PortalErrorMapping` / `PrivyErrorMapping`.
enum TurnkeyErrorMapping {
  nonisolated(unsafe) private static var registered = false
  private static let lock = NSLock()

  /// Registers the mapper exactly once per process. Called from `TurnkeyProvider.init`, so the
  /// mapper is live before any Turnkey-backed wallet call can fail.
  static func registerOnce() {
    lock.lock(); defer { lock.unlock() }
    guard !registered else { return }
    registered = true
    RainSDKError.registerErrorMapper(map)
  }

  /// Returns `nil` for non-Turnkey errors so the registry moves on to other mappers and the
  /// built-in fallbacks.
  private static func map(_ error: Error) -> RainSDKError? {
    if let turnkeySwiftError = error as? TurnkeySwiftError {
      return mapTurnkeySwiftError(turnkeySwiftError)
    }
    if let turnkeyRequestError = error as? TurnkeyRequestError {
      return mapTurnkeyRequestError(turnkeyRequestError)
    }
    return nil
  }

  private static func mapTurnkeySwiftError(_ error: TurnkeySwiftError) -> RainSDKError {
    switch error {
    case .invalidSession:
      return .tokenExpired

    case .failedToVerifyOtp(let underlying):
      // A rejected code (wrong, expired, already used) comes back from the auth proxy as a 4xx.
      // Without this, the 401 branch below would turn a mistyped code into .tokenExpired and the
      // host could not tell "retype the code" from "the session died". 400/401/403 only: 429 and
      // other statuses stay transient/provider errors.
      if let requestError = underlying as? TurnkeyRequestError,
         case .apiError(let statusCode, let payload) = requestError {
        if let statusCode, rejectedCodeStatuses.contains(statusCode) {
          return .invalidLoginCode
        }
        // The auth proxy sometimes wraps the upstream rejection in an HTTP 500 whose body embeds
        // the real status, e.g. {"code":2,"message":"turnkey: Invalid OTP code (status=400)"}.
        // Recover the embedded status and apply the same rule.
        if let embedded = embeddedUpstreamStatus(in: payload),
           rejectedCodeStatuses.contains(embedded) {
          return .invalidLoginCode
        }
      }
      return RainSDKError.from(underlying: underlying)

    case .failedToRetrieveOAuthCredential(_, let underlying):
      // May wrap ASAuthorizationError.canceled; recurse so user cancellation surfaces as .userRejected.
      return RainSDKError.from(underlying: underlying)

    case .failedToSignPayload(let underlying),
         .failedToFetchWallets(let underlying),
         .failedToCreateWallet(let underlying),
         .failedToExportWallet(let underlying),
         .failedToImportWallet(let underlying),
         .failedToStoreSession(let underlying),
         .failedToRefreshSession(let underlying),
         .failedToLoginWithPasskey(let underlying),
         .failedToSignUpWithPasskey(let underlying),
         .failedToInitOtp(let underlying),
         .failedToLoginWithOtp(let underlying),
         .failedToSignUpWithOtp(let underlying),
         .failedToCompleteOtp(let underlying),
         .failedToLoginWithOAuth(let underlying),
         .failedToSignUpWithOAuth(let underlying),
         .failedToCompleteOAuth(let underlying),
         .failedToUpdateUser(let underlying),
         .failedToUpdateUserEmail(let underlying),
         .failedToUpdateUserPhoneNumber(let underlying),
         .failedToFetchUser(let underlying),
         .failedToSetSelectedSession(let underlying),
         .keyGenerationFailed(let underlying),
         .failedToClearSession(let underlying):
      return RainSDKError.from(underlying: underlying)

    case .invalidConfiguration,
         .missingAuthProxyConfiguration,
         .invalidRefreshTTL,
         .publicKeyMissing,
         .signingNotSupported,
         .invalidJWT,
         .invalidResponse,
         .keyAlreadyExists,
         .keyNotFound,
         .keyIndexFailed,
         .keychainAddFailed,
         .oauthInvalidURL,
         .oauthMissingIDToken:
      return .internalLogicError(details: "Turnkey: \(error.localizedDescription)")
    }
  }

  /// Statuses meaning "the code itself was rejected" (wrong, expired, already used).
  private static let rejectedCodeStatuses: Set<Int> = [400, 401, 403]

  /// Extracts an upstream HTTP status the auth proxy embedded in its error body's message,
  /// e.g. `"turnkey: Invalid OTP code (status=400)"` -> 400. Returns `nil` when the payload
  /// isn't that JSON shape or carries no `status=NNN` marker.
  private static func embeddedUpstreamStatus(in payload: Data?) -> Int? {
    struct ProxyErrorBody: Decodable { let message: String }
    guard let payload,
          let body = try? JSONDecoder().decode(ProxyErrorBody.self, from: payload),
          let range = body.message.range(of: #"status=\d{3}"#, options: .regularExpression)
    else { return nil }
    return Int(body.message[range].dropFirst("status=".count))
  }

  private static func mapTurnkeyRequestError(_ error: TurnkeyRequestError) -> RainSDKError {
    switch error {
    case .apiError(let statusCode, _):
      switch statusCode {
      case 401:
        return .tokenExpired
      case 403:
        return .unauthorized
      default:
        return .providerError(underlying: error)
      }
    case .network(let underlying):
      return .networkError(underlying: underlying)
    case .sdkError(let underlying), .unknown(let underlying):
      // Underlying may be a typed error (e.g. ASAuthorizationError.canceled, NSURLError); recurse to classify it.
      return RainSDKError.from(underlying: underlying)
    case .invalidResponse:
      return .internalLogicError(details: "Turnkey invalid response")
    case .clientNotConfigured(let name):
      return .internalLogicError(details: "Turnkey client not configured: \(name)")
    }
  }
}
