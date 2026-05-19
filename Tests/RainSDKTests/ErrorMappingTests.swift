import Testing
import Foundation
import PortalSwift
import TurnkeyHttp
import TurnkeySwift
@testable import RainSDK

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

  @Test("from(_:) maps PortalRequestsError.unauthorized to tokenExpired")
  func testPortalUnauthorizedMapsToTokenExpired() {
    let mapped = RainSDKError.from(underlying: PortalRequestsError.unauthorized)
    #expect(mapped == RainSDKError.tokenExpired)
  }

  @Test("from(_:) maps PortalRequestsError.clientError with SESSION_EXPIRED message to tokenExpired")
  func testPortalClientErrorSessionExpiredMapsToTokenExpired() {
    let error = PortalRequestsError.clientError("SESSION_EXPIRED: token expired", url: "https://example.com")
    let mapped = RainSDKError.from(underlying: error)
    #expect(mapped == RainSDKError.tokenExpired)
  }

  @Test("from(_:) maps generic PortalRequestsError.clientError to providerError")
  func testPortalClientErrorGenericMapsToProviderError() {
    let error = PortalRequestsError.clientError("something else", url: "https://example.com")
    let mapped = RainSDKError.from(underlying: error)

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
}
