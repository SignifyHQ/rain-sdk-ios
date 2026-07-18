import Testing
import Foundation
import RainCore
@testable import RainPrivy

/// Wire-format coverage: node `error` objects and non-JSON bodies classify through
/// `RainSDKError.from(underlying:)`.
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

  @Test("surfaces a JSON-RPC error object with its code and message")
  func rpcErrorObject() async {
    let host = "rpc-err.rpc"
    StubURLProtocol.setHandler(host: host) { _ in RpcStub.error(code: -32000, message: "boom") }

    do {
      _ = try await client().callForHexResult(
        rpcUrl: "https://\(host)/", method: "eth_call", params: [])
      Issue.record("expected an error")
    } catch let error as RainSDKError {
      // The node's own message must survive classification (send-path simulation relies on it).
      #expect(error.errorCode == "RAIN_501")
      #expect(error.localizedDescription.contains("boom"))
    } catch {
      Issue.record("expected RainSDKError, got \(error)")
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
