import Testing
import Foundation
import TurnkeyHttp
import TurnkeySwift
@_spi(RainAdapter) @testable import RainCore
@testable import RainTurnkey

/// Turnkey halves of the error-mapping contract, moved here with the adapter. Core keeps the
/// vendor-free cases; Portal's live in RainPortalTests.
@Suite("Turnkey Error Mapping Tests")
struct TurnkeyErrorMappingTests {
  /// Turnkey mapping registers via TurnkeyErrorMapping (like Portal/Privy); these tests call
  /// RainSDKError.from directly, so make sure registration ran.
  init() { TurnkeyErrorMapping.registerOnce() }

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

  @Test(
    "from(_:) maps failedToVerifyOtp over a 4xx to invalidLoginCode",
    arguments: [400, 401, 403]
  )
  func testFailedToVerifyOtp4xxMapsToInvalidLoginCode(statusCode: Int) {
    let mapped = RainSDKError.from(underlying: TurnkeySwiftError.failedToVerifyOtp(
      underlying: TurnkeyRequestError.apiError(statusCode: statusCode, payload: nil)
    ))
    #expect(mapped == RainSDKError.invalidLoginCode)
  }

  @Test("from(_:) unwraps failedToCompleteOtp wrapping failedToVerifyOtp to invalidLoginCode")
  func testFailedToCompleteOtpWrappingVerifyMapsToInvalidLoginCode() {
    // The vendor's completeOtp wraps verifyOtp, so a wrong code arrives double-wrapped.
    let mapped = RainSDKError.from(underlying: TurnkeySwiftError.failedToCompleteOtp(
      underlying: TurnkeySwiftError.failedToVerifyOtp(
        underlying: TurnkeyRequestError.apiError(statusCode: 401, payload: nil)
      )
    ))
    #expect(mapped == RainSDKError.invalidLoginCode)
  }

  @Test("from(_:) maps failedToVerifyOtp over a proxy 500 embedding status=400 to invalidLoginCode")
  func testFailedToVerifyOtpProxy500WithEmbedded400MapsToInvalidLoginCode() {
    // The auth proxy wraps the upstream rejection in a 500 whose body leaks the real status.
    let payload = Data(#"{"code":2,"message":"turnkey: Invalid OTP code (status=400)"}"#.utf8)
    let mapped = RainSDKError.from(underlying: TurnkeySwiftError.failedToVerifyOtp(
      underlying: TurnkeyRequestError.apiError(statusCode: 500, payload: payload)
    ))
    #expect(mapped == RainSDKError.invalidLoginCode)
  }

  @Test("from(_:) keeps failedToVerifyOtp over a plain 500 out of invalidLoginCode")
  func testFailedToVerifyOtpPlain500StaysProviderError() {
    // A 500 without an embedded rejected status (or with a non-rejection one) stays a provider error.
    let payload = Data(#"{"code":13,"message":"turnkey: upstream unavailable (status=503)"}"#.utf8)
    let mapped = RainSDKError.from(underlying: TurnkeySwiftError.failedToVerifyOtp(
      underlying: TurnkeyRequestError.apiError(statusCode: 500, payload: payload)
    ))
    #expect(mapped != RainSDKError.invalidLoginCode)
  }

  @Test("from(_:) keeps failedToVerifyOtp over 429 out of invalidLoginCode")
  func testFailedToVerifyOtp429StaysTransient() {
    // Rate limiting is not a wrong code; it falls through to the generic status mapping.
    let mapped = RainSDKError.from(underlying: TurnkeySwiftError.failedToVerifyOtp(
      underlying: TurnkeyRequestError.apiError(statusCode: 429, payload: nil)
    ))
    #expect(mapped != RainSDKError.invalidLoginCode)
    if case .providerError = mapped {
      // OK — transient/provider classification preserved.
    } else {
      Issue.record("Expected .providerError, got \(mapped)")
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
}
