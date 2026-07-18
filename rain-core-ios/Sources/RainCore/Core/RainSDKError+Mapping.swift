import AuthenticationServices
import Foundation
import TurnkeyHttp
import TurnkeySwift

// MARK: - Map provider errors to RainSDKError

extension RainSDKError {
  /// A closure that attempts to map a vendor error into a `RainSDKError`, returning `nil` if it
  /// doesn't recognize the error. Out-of-core adapters (e.g. `RainPortal`) register one of these
  /// so their vendor errors classify correctly without core importing the vendor SDK.
  public typealias ErrorMapper = @Sendable (_ error: Error) -> RainSDKError?

  /// Registered adapter mappers, consulted (in registration order) before the built-in fallbacks.
  nonisolated(unsafe) private static var externalMappers: [ErrorMapper] = []
  private static let externalMappersLock = NSLock()

  /// Registers an adapter's error mapper. Called from an adapter module (e.g. `RainPortal`) so
  /// core can classify that adapter's vendor errors without a compile-time dependency on it.
  /// Idempotent per process is the caller's responsibility; typically invoked once when the
  /// adapter's provider is constructed.
  public static func registerErrorMapper(_ mapper: @escaping ErrorMapper) {
    externalMappersLock.lock()
    defer { externalMappersLock.unlock() }
    externalMappers.append(mapper)
  }

  private static func mapExternal(_ error: Error) -> RainSDKError? {
    externalMappersLock.lock()
    let mappers = externalMappers
    externalMappersLock.unlock()
    for mapper in mappers {
      if let mapped = mapper(error) { return mapped }
    }
    return nil
  }

  /// Maps a thrown error (e.g. from Turnkey, or an adapter-registered vendor) to a `RainSDKError`.
  /// Common cases (session expired, network, user cancellation) are mapped explicitly; everything
  /// else is `providerError(underlying:)`.
  public static func from(underlying error: Error) -> RainSDKError {
    if let rain = error as? RainSDKError { return rain }

    // Adapter-registered mappers (e.g. Portal) get first crack at their own vendor errors.
    if let mapped = mapExternal(error) { return mapped }

    if let turnkeySwiftError = error as? TurnkeySwiftError {
      return mapTurnkeySwiftError(turnkeySwiftError)
    }

    if let turnkeyRequestError = error as? TurnkeyRequestError {
      return mapTurnkeyRequestError(turnkeyRequestError)
    }

    let nsError = error as NSError
    if nsError.domain == ASAuthorizationError.errorDomain,
       nsError.code == ASAuthorizationError.canceled.rawValue {
      return .userRejected
    }

    if nsError.domain == NSURLErrorDomain {
      return .networkError(underlying: error)
    }

    return .providerError(underlying: error)
  }

  private static func mapTurnkeySwiftError(_ error: TurnkeySwiftError) -> RainSDKError {
    switch error {
    case .invalidSession:
      return .tokenExpired

    case .failedToRetrieveOAuthCredential(_, let underlying):
      // May wrap ASAuthorizationError.canceled; recurse so user cancellation surfaces as .userRejected.
      return from(underlying: underlying)

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
         .failedToVerifyOtp(let underlying),
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
      return from(underlying: underlying)

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
      return from(underlying: underlying)
    case .invalidResponse:
      return .internalLogicError(details: "Turnkey invalid response")
    case .clientNotConfigured(let name):
      return .internalLogicError(details: "Turnkey client not configured: \(name)")
    }
  }
}
