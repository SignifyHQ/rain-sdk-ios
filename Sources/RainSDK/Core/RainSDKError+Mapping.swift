import AuthenticationServices
import Foundation
import PortalSwift
import TurnkeyHttp
import TurnkeySwift

// MARK: - Map provider errors to RainSDKError

extension RainSDKError {
  /// Maps a thrown error (e.g. from Portal or Turnkey) to a `RainSDKError`.
  /// Common cases (session expired, network, user cancellation) are mapped explicitly; everything else is `providerError(underlying:)`.
  internal static func from(underlying error: Error) -> RainSDKError {
    if let rain = error as? RainSDKError { return rain }

    if let requestError = error as? PortalRequestsError {
      return mapPortalRequestsError(requestError)
    }

    if let mpcError = error as? PortalMpcError {
      return mapPortalMpcError(mpcError)
    }

    if let rpcError = error as? PortalRpcError {
      return mapPortalRpcError(rpcError)
    }

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

  private static func mapPortalRequestsError(_ error: PortalRequestsError) -> RainSDKError {
    switch error {
    case .unauthorized:
      return .tokenExpired
    case .clientError(let message, _):
      // Portal wording varies; match defensively on the message body.
      if message.contains("SESSION_EXPIRED") || message.contains("401") {
        return .tokenExpired
      }
      return .providerError(underlying: error)
    case .internalServerError, .redirectError:
      return .providerError(underlying: error)
    default:
      return .providerError(underlying: error)
    }
  }

  private static func mapPortalMpcError(_ error: PortalMpcError) -> RainSDKError {
    // Common: session expired / invalid API key
    let code = error.id.flatMap { Int($0) }
    if code == 320 || code == PortalErrorCodes.INVALID_API_KEY.rawValue {
      return .tokenExpired
    }
    
    // BAD_REQUEST and all other codes: not mapped to userRejected (message wording varies by Portal; app can inspect underlying error)
    return .providerError(underlying: error)
  }

  private static func mapPortalRpcError(_ error: PortalRpcError) -> RainSDKError {
    // Code `3` is returned for "execution reverted" — not declared by PortalSwift
    if error.code == 3 {
      return .withdrawalRevertedByNetwork
    }
    
    // BAD_REQUEST and all other codes: not mapped to userRejected (message wording varies by Portal; app can inspect underlying error)
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
