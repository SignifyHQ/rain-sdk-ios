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
  /// Typed cases (session expired, network, user cancellation) are mapped first, then untyped
  /// vendor prose by keyword; everything else is `providerError(underlying:)`.
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

    // Last resort before the generic wrap: vendors that surface a rejection or a funds shortfall
    // only as prose still have to classify, or the same failure reports a different code per
    // provider. Adapter mappers and the typed checks above always win over these.
    if let keyworded = mapByKeyword(error) { return keyworded }

    return .providerError(underlying: error)
  }

  /// Classifies an untyped vendor error by its message, or by EIP-1193 code 4001 when the error
  /// carries one.
  private static func mapByKeyword(_ error: Error) -> RainSDKError? {
    // Task cancellation is not a wallet-UI rejection, and its type name would match "cancel".
    if error is CancellationError { return nil }

    // EIP-1193 / wallet-standard "User Rejected Request".
    if (error as NSError).code == userRejectedCode { return .userRejected }

    // Both renderings: localizedDescription for LocalizedError/NSError prose, and the debug
    // description — a plain Swift error's localizedDescription is a generic placeholder.
    return fromVendorMessage(String(describing: error) + " " + (error as NSError).localizedDescription)
  }

  /// EIP-1193 `userRejectedRequest`; Solana wallet-standard reuses the same code.
  private static let userRejectedCode = 4001

  /// Phrases that classify a vendor message. Every entry is at least two words so a lone
  /// "rejected", "cancelled" or "insufficient" never classifies on its own: "Transaction
  /// cancelled" or "User doesn't have an embedded wallet" are not user rejections.
  static let userRejectedPhrases: [String] = [
    "user rejected", "user denied", "user cancelled", "user canceled", "user declined",
    "rejected by user", "denied by user", "cancelled by user", "canceled by user",
    "rejected by the user", "denied by the user", "cancelled by the user", "canceled by the user",
  ]
  static let insufficientFundsPhrases: [String] = [
    "insufficient funds", "insufficient balance", "insufficient lamports",
    // Solana: "Attempt to debit an account but found no record of a prior credit".
    "found no record of a prior credit",
  ]

  /// Classifies free-text vendor prose into `.userRejected` / `.insufficientFunds`, or `nil` when
  /// the message matches neither. Shared with adapters so every vendor is held to one standard.
  public static func fromVendorMessage(_ message: String) -> RainSDKError? {
    let text = normalizedVendorText(message)
    guard !text.isEmpty else { return nil }
    if text.range(of: #"\bcode\W{0,3}4001\b|[\[(]4001[\])]"#, options: .regularExpression) != nil {
      return .userRejected
    }
    if userRejectedPhrases.contains(where: text.contains) {
      return .userRejected
    }
    if insufficientFundsPhrases.contains(where: text.contains) {
      return .insufficientFunds(required: "unknown", available: "unknown")
    }
    return nil
  }

  /// Lowercases and splits camelCase so an enum case like `userRejectedSignature` reads as prose.
  private static func normalizedVendorText(_ message: String) -> String {
    var out = ""
    out.reserveCapacity(message.count + 8)
    var previousWasLower = false
    for ch in message {
      if ch.isUppercase, previousWasLower { out.append(" ") }
      out.append(ch)
      previousWasLower = ch.isLowercase
    }
    return out.lowercased()
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
