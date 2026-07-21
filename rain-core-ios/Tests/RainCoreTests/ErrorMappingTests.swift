import Testing
import Foundation
import TurnkeyHttp
import TurnkeySwift
@testable import RainCore

/// Turnkey + generic error-mapping cases. Portal error mapping is registered at runtime by
/// `PortalProvider` (so RainCore never imports PortalSwift); those cases live in `RainPortalTests`.
@Suite("RainSDKError Mapping Tests")
struct ErrorMappingTests {

  @Test("from(_:) returns RainSDKError unchanged when input is already a RainSDKError")
  func testRainSDKErrorPassthrough() {
    let original = RainSDKError.invalidConfig(chainId: 5, rpcUrl: "x")
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

  // Pins the error-code map shared with the Android SDK (see its RainErrorCodeParityTest).
  // A failure here means the platforms have drifted — fix the code, not the test.
  @Test("error codes match the cross-platform map")
  func testErrorCodeParityMap() {
    let underlying = NSError(domain: "Test", code: 1, userInfo: nil)
    let expected: [(RainSDKError, String)] = [
      (.sdkNotInitialized, "RAIN_101"),
      (.invalidConfig(chainId: 1, rpcUrl: "x"), "RAIN_102"),
      (.providerNotRegistered(details: "x"), "RAIN_102"),
      (.invalidRpcUrl("x"), "RAIN_103"),
      (.rainApiNotConfigured, "RAIN_104"),
      (.tokenExpired, "RAIN_201"),
      (.unauthorized, "RAIN_202"),
      (.networkError(underlying: underlying), "RAIN_301"),
      (.apiError(statusCode: 500, message: "x"), "RAIN_302"),
      (.signatureNotReady(status: "pending", retryAfter: 30), "RAIN_303"),
      (.noCollateralContracts, "RAIN_304"),
      (.userRejected, "RAIN_401"),
      (.insufficientFunds(required: "1", available: "0"), "RAIN_402"),
      (.transactionSimulationFailed(underlying: underlying), "RAIN_403"),
      (.walletUnavailable, "RAIN_404"),
      (.withdrawalRevertedByNetwork, "RAIN_405"),
      (.invalidAmount(amount: "1.005", reason: "too many decimals"), "RAIN_406"),
      (.walletNotAuthorized(walletAddress: "0x1", proxyAddress: "0x2"), "RAIN_407"),
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
         .noCollateralContracts,
         .userRejected,
         .insufficientFunds,
         .transactionSimulationFailed,
         .walletUnavailable,
         .withdrawalRevertedByNetwork,
         .invalidAmount,
         .walletNotAuthorized,
         .providerError,
         .internalLogicError:
      break
    }
  }
}
