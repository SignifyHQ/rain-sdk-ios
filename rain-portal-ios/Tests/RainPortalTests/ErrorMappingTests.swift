import Testing
import Foundation
@testable import PortalSwift
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

  @Test("from(_:) maps PortalRpcError code 3 to transactionSimulationFailed, not withdrawalRevertedByNetwork")
  func testPortalRpcErrorCode3MapsToSimulationFailed() {
    let error = PortalRpcError(PortalProviderRpcResponseError(code: 3, message: "execution reverted"))
    let mapped = RainSDKError.from(underlying: error)

    // Code 3 only reaches this mapper from send / fee-estimation flows; the withdrawal-specific
    // RAIN_405 classification happens in core, on the withdrawal paths only.
    #expect(mapped == RainSDKError.transactionSimulationFailed(underlying: error))
    #expect(mapped.errorCode == "RAIN_403")
  }

  @Test("from(_:) maps other PortalRpcError codes to providerError")
  func testPortalRpcErrorOtherCodeMapsToProviderError() {
    let error = PortalRpcError(PortalProviderRpcResponseError(code: -32000, message: "boom"))
    let mapped = RainSDKError.from(underlying: error)

    #expect(mapped == RainSDKError.providerError(underlying: error))
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
