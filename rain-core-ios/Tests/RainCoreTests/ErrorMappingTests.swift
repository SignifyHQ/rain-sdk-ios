import Testing
import Foundation
import TurnkeyHttp
import TurnkeySwift
@testable import RainCore

/// Turnkey + generic error-mapping cases. Portal error mapping is registered at runtime by
/// `PortalProvider` (so RainCore never imports PortalSwift); those cases live in `RainPortalTests`.
@Suite("RainSDKError Mapping Tests")
struct ErrorMappingTests {
  /// Turnkey mapping now registers via TurnkeyErrorMapping (like Portal/Privy);
  /// tests exercising RainSDKError.from with Turnkey errors must ensure it ran.
  init() { TurnkeyErrorMapping.registerOnce() }


  @Test("from(_:) returns RainSDKError unchanged when input is already a RainSDKError")
  func testRainSDKErrorPassthrough() {
    let original = RainSDKError.invalidConfig(details: "x")
    let mapped = RainSDKError.from(underlying: original)
    #expect(mapped == original)
  }

  @Test("from(_:) maps NSURLErrorDomain errors to networkError")
  func testNSURLErrorMapsToNetworkError() {
    let underlying = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
    let mapped = RainSDKError.from(underlying: underlying)

    if case .networkError = mapped {
      // OK
    } else {
      Issue.record("Expected .networkError, got \(mapped)")
    }
  }

  @Test("from(_:) maps unknown NSError to providerError")
  func testUnknownErrorMapsToProviderError() {
    let underlying = NSError(domain: "SomeRandomDomain", code: 123, userInfo: nil)
    let mapped = RainSDKError.from(underlying: underlying)

    if case .providerError = mapped {
      // OK
    } else {
      Issue.record("Expected .providerError, got \(mapped)")
    }
  }

  @Test("from(_:) maps TurnkeySwiftError.invalidSession to tokenExpired")
  func testTurnkeyInvalidSessionMapsToTokenExpired() {
    let mapped = RainSDKError.from(underlying: TurnkeySwiftError.invalidSession)
    #expect(mapped == RainSDKError.tokenExpired)
  }

  @Test("from(_:) unwraps TurnkeySwiftError.failedToSignPayload and classifies the inner error")
  func testTurnkeyFailedToSignPayloadUnwraps() {
    let inner = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
    let mapped = RainSDKError.from(underlying: TurnkeySwiftError.failedToSignPayload(underlying: inner))

    if case .networkError = mapped {
      // OK — recursed into NSURLError mapping.
    } else {
      Issue.record("Expected .networkError, got \(mapped)")
    }
  }

  @Test("from(_:) maps TurnkeyRequestError.apiError 401 to tokenExpired")
  func testTurnkeyApiError401() {
    let mapped = RainSDKError.from(underlying: TurnkeyRequestError.apiError(statusCode: 401, payload: nil))
    #expect(mapped == RainSDKError.tokenExpired)
  }

  @Test("from(_:) maps TurnkeyRequestError.apiError 403 to unauthorized")
  func testTurnkeyApiError403() {
    let mapped = RainSDKError.from(underlying: TurnkeyRequestError.apiError(statusCode: 403, payload: nil))
    #expect(mapped == RainSDKError.unauthorized)
  }

  @Test("from(_:) maps TurnkeyRequestError.network to networkError")
  func testTurnkeyRequestNetworkMapsToNetworkError() {
    let underlying = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
    let mapped = RainSDKError.from(underlying: TurnkeyRequestError.network(underlying))

    if case .networkError = mapped {
      // OK
    } else {
      Issue.record("Expected .networkError, got \(mapped)")
    }
  }

  @Test("from(_:) maps TurnkeyRequestError.invalidResponse to internalLogicError")
  func testTurnkeyInvalidResponseMapsToInternalLogicError() {
    let mapped = RainSDKError.from(underlying: TurnkeyRequestError.invalidResponse)

    if case .internalLogicError = mapped {
      // OK
    } else {
      Issue.record("Expected .internalLogicError, got \(mapped)")
    }
  }

  // Pins the published error-code map — a contract host apps switch on.
  // A failure here means the platforms have drifted — fix the code, not the test.
  @Test("error codes match the cross-platform map")
  func testErrorCodeParityMap() {
    let underlying = NSError(domain: "Test", code: 1, userInfo: nil)
    let expected: [(RainSDKError, String)] = [
      (.sdkNotInitialized, "RAIN_101"),
      (.invalidConfig(details: "x"), "RAIN_102"),
      (.providerNotRegistered(details: "x"), "RAIN_102"),
      (.invalidRpcUrl("x"), "RAIN_103"),
      (.rainApiNotConfigured, "RAIN_104"),
      (.tokenExpired, "RAIN_201"),
      (.unauthorized, "RAIN_202"),
      (.networkError(underlying: underlying), "RAIN_301"),
      (.apiError(statusCode: 500, message: "x"), "RAIN_302"),
      (.signatureNotReady(status: "pending", retryAfter: 30), "RAIN_303"),
      (.transactionPending(statusId: "status-1"), "RAIN_303"),
      (.noCollateralContracts, "RAIN_304"),
      (.userRejected, "RAIN_401"),
      (.insufficientFunds(required: "1", available: "0"), "RAIN_402"),
      (.transactionSimulationFailed(underlying: underlying), "RAIN_403"),
      (.walletUnavailable, "RAIN_404"),
      (.withdrawalRevertedByNetwork, "RAIN_405"),
      (.invalidAmount(amount: "1.005", reason: "too many decimals"), "RAIN_406"),
      (.walletNotAuthorized(walletAddress: "0x1", proxyAddress: "0x2"), "RAIN_407"),
      // Token-transfer failures reuse existing codes on purpose — the code map is shared with the
      // published contract, so a new code would fork it.
      (.insufficientTokenBalance(requested: "2", available: "1", token: "mint"), "RAIN_402"),
      (.tokenAccountNotFound(walletAddress: "wallet", token: "mint"), "RAIN_402"),
      (.tokenNotFound(token: "mint", chainId: 103), "RAIN_102"),
      (.invalidRecipient(address: "addr", reason: "because"), "RAIN_102"),
      (.providerError(underlying: underlying), "RAIN_501"),
      (.internalLogicError(details: "x"), "RAIN_502"),
    ]
    for (error, code) in expected {
      #expect(error.errorCode == code)
      requireMappedCase(error)
    }
  }

  /// Fails to compile when a `RainSDKError` case is added but not listed here.
  private func requireMappedCase(_ error: RainSDKError) {
    switch error {
    case .sdkNotInitialized,
         .invalidConfig,
         .providerNotRegistered,
         .invalidRpcUrl,
         .rainApiNotConfigured,
         .tokenExpired,
         .unauthorized,
         .networkError,
         .apiError,
         .signatureNotReady,
         .transactionPending,
         .noCollateralContracts,
         .userRejected,
         .insufficientFunds,
         .transactionSimulationFailed,
         .walletUnavailable,
         .withdrawalRevertedByNetwork,
         .invalidAmount,
         .walletNotAuthorized,
         .insufficientTokenBalance,
         .tokenAccountNotFound,
         .tokenNotFound,
         .invalidRecipient,
         .providerError,
         .internalLogicError:
      break
    }
  }

  // MARK: - Equality

  @Test("== distinguishes different cases that share an error code")
  func testEqualityDistinguishesCasesSharingACode() {
    // RAIN_402 trio
    #expect(
      RainSDKError.insufficientFunds(required: "1", available: "0")
        != RainSDKError.tokenAccountNotFound(walletAddress: "w", token: "t")
    )
    #expect(
      RainSDKError.insufficientFunds(required: "1", available: "0")
        != RainSDKError.insufficientTokenBalance(requested: "2", available: "1", token: "t")
    )
    // RAIN_303 pair
    #expect(
      RainSDKError.signatureNotReady(status: "pending", retryAfter: 30)
        != RainSDKError.transactionPending(statusId: "s")
    )
    // RAIN_102 family
    #expect(RainSDKError.invalidConfig(details: "x") != RainSDKError.tokenNotFound(token: "t", chainId: 1))
    #expect(RainSDKError.invalidConfig(details: "x") != RainSDKError.providerNotRegistered(details: "x"))
    #expect(
      RainSDKError.tokenNotFound(token: "t", chainId: 1)
        != RainSDKError.invalidRecipient(address: "a", reason: "r")
    )
  }

  @Test("== treats same-case values as equal regardless of payload")
  func testEqualityIsPayloadInsensitive() {
    #expect(RainSDKError.invalidConfig(details: "a") == RainSDKError.invalidConfig(details: "b"))
    #expect(
      RainSDKError.insufficientFunds(required: "1", available: "0")
        == RainSDKError.insufficientFunds(required: "9", available: "8")
    )
    #expect(RainSDKError.unauthorized == RainSDKError.unauthorized)
    #expect(RainSDKError.tokenExpired == RainSDKError.tokenExpired)
  }

  // MARK: - Untyped vendor prose
  //
  // Standard: a message classifies only on a phrase of at least two words (or EIP-1193 code
  // 4001). A lone "rejected" / "cancelled" / "insufficient" is not enough.

  @Test("from(_:) maps a user-rejection phrase to userRejected")
  func testRejectionPhrasesMapToUserRejected() {
    for message in [
      "User rejected the request",
      "User denied transaction signature",
      "User cancelled signing",
      "User canceled signing",
      "User declined the request",
      "Signature rejected by user",
      "Request denied by user",
      "Transaction cancelled by user",
      "Request denied by the user",
    ] {
      let mapped = RainSDKError.from(underlying: VendorProseError(message))
      #expect(mapped == RainSDKError.userRejected, "expected userRejected for: \(message)")
    }
  }

  @Test("from(_:) maps EIP-1193 code 4001 to userRejected")
  func testCode4001MapsToUserRejected() {
    for message in ["code: 4001, message: nope", "RPC error [4001]", "Provider error (4001)"] {
      let mapped = RainSDKError.from(underlying: VendorProseError(message))
      #expect(mapped == RainSDKError.userRejected, "expected userRejected for: \(message)")
    }
    let coded = NSError(domain: "vendor", code: 4001, userInfo: nil)
    #expect(RainSDKError.from(underlying: coded) == RainSDKError.userRejected)
  }

  @Test("from(_:) maps an insufficient-funds phrase to insufficientFunds")
  func testInsufficientPhrasesMapToInsufficientFunds() {
    for message in [
      "insufficient funds for gas * price + value",
      "Insufficient balance for transfer",
      "Transfer: insufficient lamports 100, need 5000",
      "Attempt to debit an account but found no record of a prior credit.",
    ] {
      let mapped = RainSDKError.from(underlying: VendorProseError(message))
      #expect(mapped.errorCode == "RAIN_402", "expected RAIN_402 for: \(message)")
    }
  }

  @Test("from(_:) leaves an unrecognized message as providerError")
  func testUnrecognizedProseStaysProviderError() {
    let mapped = RainSDKError.from(underlying: VendorProseError("nonce too low"))
    if case .providerError = mapped {} else {
      Issue.record("expected providerError, got \(mapped)")
    }
  }

  @Test("from(_:) does not classify on a single word")
  func testSingleWordDoesNotClassify() {
    for message in [
      "User doesn't have an embedded wallet",
      "Transaction cancelled",
      "request was denied",
      "Rejected: nonce too low",
      "insufficient permissions for this operation",
      "nonce 4001 too low",
    ] {
      let mapped = RainSDKError.from(underlying: VendorProseError(message))
      if case .providerError = mapped {} else {
        Issue.record("expected providerError for: \(message), got \(mapped)")
      }
    }
  }

  // Plain Swift errors (no LocalizedError) render a generic localizedDescription, so
  // classification must also read the debug description, splitting camelCase case names.

  @Test("from(_:) classifies a plain Swift error whose case text says insufficient funds")
  func testPlainErrorInsufficientFunds() {
    let mapped = RainSDKError.from(underlying: PlainVendorError.insufficientFundsForTransfer)
    #expect(mapped == RainSDKError.insufficientFunds(required: "unknown", available: "unknown"))

    let prose = RainSDKError.from(underlying: PlainVendorError.prose("insufficient funds for gas"))
    #expect(prose == RainSDKError.insufficientFunds(required: "unknown", available: "unknown"))
  }

  @Test("from(_:) classifies a plain Swift error whose case text says the user rejected")
  func testPlainErrorUserRejection() {
    #expect(RainSDKError.from(underlying: PlainVendorError.userRejectedSignature) == RainSDKError.userRejected)
    #expect(RainSDKError.from(underlying: PlainVendorError.prose("denied by user")) == RainSDKError.userRejected)
  }

  @Test("from(_:) does not classify Task cancellation as a user rejection")
  func testCancellationErrorIsNotUserRejected() {
    let mapped = RainSDKError.from(underlying: CancellationError())
    if case .providerError = mapped {} else {
      Issue.record("expected providerError, got \(mapped)")
    }
  }
}

/// A vendor error that carries its meaning only in prose — the shape the keyword fallback exists
/// for, and the shape Portal and Turnkey both produce for rejections and funds shortfalls.
private struct VendorProseError: LocalizedError {
  let errorDescription: String?
  init(_ message: String) { self.errorDescription = message }
}

/// A plain Swift error (not LocalizedError): its meaning lives only in the case name or
/// associated text, and its localizedDescription is the generic NSError placeholder.
private enum PlainVendorError: Error {
  case insufficientFundsForTransfer
  case userRejectedSignature
  case prose(String)
}
