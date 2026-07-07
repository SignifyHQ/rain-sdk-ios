import Testing
import Foundation
import PortalSwift
@testable import RainCore
@testable import RainPortal

/// Portal-specific error mapping. Portal's mapper is registered with RainCore at runtime (so
/// RainCore never imports PortalSwift), inside `PortalProvider.init` / `PortalErrorMapping
/// .registerOnce()`. We trigger that registration before asserting. The Turnkey/generic cases live
/// in `RainCoreTests/ErrorMappingTests`.
@Suite("Portal Error Mapping Tests")
struct PortalErrorMappingTests {

  /// Ensures Portal's error mapper is registered with RainCore before any assertion runs.
  init() {
    PortalErrorMapping.registerOnce()
  }

  @Test("from(_:) maps PortalRequestsError.unauthorized to tokenExpired")
  func testPortalUnauthorizedMapsToTokenExpired() {
    let mapped = RainSDKError.from(underlying: PortalRequestsError.unauthorized)
    #expect(mapped == RainSDKError.tokenExpired)
  }

  @Test("from(_:) maps PortalRequestsError.clientError to providerError")
  func testPortalClientErrorMapsToProviderError() {
    // Portal routes 401 to .unauthorized upstream, so .clientError only carries
    // other 4xx responses — all of which surface as providerError.
    let error = PortalRequestsError.clientError("403 - Forbidden", url: "https://example.com")
    let mapped = RainSDKError.from(underlying: error)

    if case .providerError = mapped {
      // OK
    } else {
      Issue.record("Expected .providerError, got \(mapped)")
    }
  }
}
