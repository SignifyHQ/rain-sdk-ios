import Foundation
import PortalSwift

// MARK: - Map Portal / provider errors to RainSDKError

extension RainSDKError {
  /// Maps a thrown error (e.g. from Portal) to a `RainSDKError`.
  /// Only common cases (session expired, network) are mapped; everything else is `providerError(underlying:)`.
  internal static func from(underlying error: Error) -> RainSDKError {
    if let rain = error as? RainSDKError { return rain }

    if let requestError = error as? PortalRequestsError {
      return mapPortalRequestsError(requestError)
    }

    if let mpcError = error as? PortalMpcError {
      return mapPortalMpcError(mpcError)
    }

    if (error as NSError).domain == NSURLErrorDomain {
      return .networkError(underlying: error)
    }

    return .providerError(underlying: error)
  }

  private static func mapPortalRequestsError(_ error: PortalRequestsError) -> RainSDKError {
    switch error {
    case .unauthorized:
      return .tokenExpired(token: "")
    case .clientError(let message, _):
      if message.contains("SESSION_EXPIRED") || message.contains("401") {
        return .tokenExpired(token: "")
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
    let code = error.code
    if code == 320 || code == PortalErrorCodes.INVALID_API_KEY.rawValue {
      return .tokenExpired(token: "")
    }

    // BAD_REQUEST and all other codes: not mapped to userRejected (message wording varies by Portal; app can inspect underlying error)
    return .providerError(underlying: error)
  }
}
