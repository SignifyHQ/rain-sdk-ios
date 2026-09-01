import Testing
import Foundation
import RainCore
@testable import RainPrivy

/// Wire-format coverage: node `error` objects classify purpose-aware inside the client,
/// transport failures and non-JSON bodies go through `RainSDKError.from(underlying:)`.
@Suite("Privy RPC Client Tests")
struct PrivyRpcClientTests {
  private func client() -> PrivyRpcClient {
    PrivyRpcClient(session: StubURLProtocol.makeSession())
  }

  @Test("returns the hex result on a well-formed response")
  func wellFormedResult() async throws {
    let host = "rpc-ok.rpc"
    StubURLProtocol.setHandler(host: host) { _ in RpcStub.result("0x2a") }

    let result = try await client().callForHexResult(
      rpcUrl: "https://\(host)/", method: "eth_getBalance", params: ["0xabc", "latest"])
    #expect(result == "0x2a")
  }

  @Test("surfaces an unrecognized JSON-RPC error object as internalLogicError with code and message")
  func rpcErrorObject() async {
    let host = "rpc-err.rpc"
    StubURLProtocol.setHandler(host: host) { _ in RpcStub.error(code: -32000, message: "boom") }

    do {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_call", params: [])
      Issue.record("expected an error")
    } catch let error as RainSDKError {
      // The node's own code and message must survive classification in the details.
      #expect(error.errorCode == "RAIN_502")
      #expect(error.localizedDescription.contains("boom"))
      #expect(error.localizedDescription.contains("-32000"))
    } catch {
      Issue.record("expected RainSDKError, got \(error)")
    }
  }

  // MARK: - Purpose-aware node-error classification

  @Test("simulation: a revert maps to transactionSimulationFailed")
  func simulationRevertClassifies() async {
    let host = "rpc-sim-revert.rpc"
    StubURLProtocol.setHandler(host: host) { _ in
      RpcStub.error(code: 3, message: "execution reverted")
    }

    await #expect(throws: RainSDKError.transactionSimulationFailed(underlying: NSError(domain: "", code: 0))) {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_call", params: [], purpose: .simulation)
    }
  }

  @Test("simulation: revert is checked before insufficient funds")
  func simulationRevertBeatsInsufficient() async {
    let host = "rpc-sim-order.rpc"
    StubURLProtocol.setHandler(host: host) { _ in
      RpcStub.error(code: 3, message: "execution reverted: insufficient funds for transfer")
    }

    await #expect(throws: RainSDKError.transactionSimulationFailed(underlying: NSError(domain: "", code: 0))) {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_call", params: [], purpose: .simulation)
    }
  }

  @Test("read: insufficient funds maps to insufficientFunds")
  func readInsufficientFundsClassifies() async {
    let host = "rpc-read-funds.rpc"
    StubURLProtocol.setHandler(host: host) { _ in
      RpcStub.error(code: -32000, message: "insufficient funds for gas * price + value")
    }

    await #expect(throws: RainSDKError.insufficientFunds(required: "", available: "")) {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_estimateGas", params: [])
    }
  }

  @Test("read: access denied maps to internalLogicError, not userRejected")
  func readAccessDeniedIsNotUserRejected() async {
    let host = "rpc-read-denied.rpc"
    StubURLProtocol.setHandler(host: host) { _ in
      RpcStub.error(code: -32000, message: "access denied")
    }

    // A node message is never a user action; the old keyword mapping misfiled this as RAIN_401.
    await #expect(throws: RainSDKError.internalLogicError(details: "")) {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_getBalance", params: [])
    }
  }

  @Test("read: a revert maps to internalLogicError, not a simulation verdict")
  func readRevertIsInternal() async {
    let host = "rpc-read-revert.rpc"
    StubURLProtocol.setHandler(host: host) { _ in
      RpcStub.error(code: 3, message: "execution reverted")
    }

    await #expect(throws: RainSDKError.internalLogicError(details: "")) {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_call", params: [])
    }
  }

  @Test("maps a non-string result to internalLogicError")
  func nonStringResult() async {
    let host = "rpc-nonstring.rpc"
    StubURLProtocol.setHandler(host: host) { _ in RpcStub.rawResult(["unexpected": true]) }

    await #expect(throws: RainSDKError.internalLogicError(details: "")) {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_getBalance", params: [])
    }
  }

  @Test("maps a non-JSON body to a RainSDKError")
  func nonJsonBody() async {
    let host = "rpc-nonjson.rpc"
    StubURLProtocol.setHandler(host: host) { _ in Data("not json at all".utf8) }

    await #expect(throws: RainSDKError.self) {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_getBalance", params: [])
    }
  }

  @Test("rejects an unparseable RPC url with invalidRpcUrl")
  func invalidUrl() async {
    await #expect(throws: RainSDKError.invalidRpcUrl("")) {
      _ = try await client().callForHexResult(
        rpcUrl: "", method: "eth_getBalance", params: [])
    }
  }

  @Test("maps a transport failure to networkError")
  func transportFailure() async {
    // No handler registered for this host → the stub fails the load with a URLError.
    do {
      _ = try await client().callForHexResult(
        rpcUrl: "https://rpc-unreachable.rpc/", method: "eth_getBalance", params: [])
      Issue.record("expected an error")
    } catch let error as RainSDKError {
      #expect(error.errorCode == "RAIN_301")
    } catch {
      Issue.record("expected RainSDKError, got \(error)")
    }
  }
}
