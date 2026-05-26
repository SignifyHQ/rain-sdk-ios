import Foundation

/// Minimal JSON-RPC 2.0 client used by the SDK's chain-read layer.
///
/// Owned by `EVMChainReader` and reused by `TurnkeyWalletProviderAdapter` for its
/// `eth_*` calls (gas, nonce, transaction submission helpers), so the SDK has one
/// HTTP+JSON-RPC implementation rather than per-adapter copies.
///
/// Stays small on purpose — wire format and error mapping match what
/// `TurnkeyWalletProviderAdapter.rpcRequest` did historically.
internal final class JsonRpcClient: Sendable {
  private let session: URLSession
  private let timeout: TimeInterval

  internal init(
    session: URLSession = .shared,
    timeout: TimeInterval = 10
  ) {
    self.session = session
    self.timeout = timeout
  }

  /// Sends a single JSON-RPC 2.0 request and returns the parsed response dictionary.
  /// Throws `RainSDKError.invalidConfig` on bad URLs, `.internalLogicError` on malformed
  /// payloads, and wraps RPC `error` objects as `NSError(domain: "eth.rpc", ...)` mapped
  /// through `RainSDKError.from(underlying:)`.
  internal func call(
    rpcUrl: String,
    method: String,
    params: [Any]
  ) async throws -> [String: Any] {
    guard let url = URL(string: rpcUrl) else {
      throw RainSDKError.invalidConfig(chainId: 0, rpcUrl: rpcUrl)
    }

    do {
      var request = URLRequest(url: url, timeoutInterval: timeout)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONSerialization.data(
        withJSONObject: [
          "jsonrpc": "2.0",
          "id": 1,
          "method": method,
          "params": params
        ]
      )

      let (data, _) = try await session.data(for: request)
      guard let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw RainSDKError.internalLogicError(
          details: "Unexpected RPC response payload for method \(method)"
        )
      }

      if let error = response["error"] as? [String: Any] {
        let code = error["code"] as? Int ?? -1
        let message = error["message"] as? String ?? "Unknown RPC error"
        throw NSError(
          domain: "eth.rpc",
          code: code,
          userInfo: [NSLocalizedDescriptionKey: message]
        )
      }

      return response
    } catch let error as RainSDKError {
      throw error
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  /// Convenience wrapper that extracts the `result` field as a String.
  /// Throws `.internalLogicError` if the field is missing or not a string.
  internal func callForHexResult(
    rpcUrl: String,
    method: String,
    params: [Any]
  ) async throws -> String {
    let response = try await call(rpcUrl: rpcUrl, method: method, params: params)
    guard let result = response["result"] as? String else {
      throw RainSDKError.internalLogicError(
        details: "Unexpected RPC result for method \(method)"
      )
    }
    return result
  }
}
