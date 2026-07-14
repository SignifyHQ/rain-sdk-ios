import Foundation
import RainCore

/// Minimal JSON-RPC 2.0 client for Privy's read path (balances, gas, fee estimates, and the
/// pre-broadcast `eth_call` simulation).
///
/// Privy's EIP-1193 provider is reserved for custody (sign / send); everything read-only goes
/// through here against the RPC endpoints Rain was configured with.
final class PrivyRpcClient: Sendable {
  private let session: URLSession
  private let timeout: TimeInterval

  init(session: URLSession = .shared, timeout: TimeInterval = 10) {
    self.session = session
    self.timeout = timeout
  }

  /// Sends a single JSON-RPC 2.0 request and returns the `result` field as a String.
  func callForHexResult(
    rpcUrl: String,
    method: String,
    params: [Any]
  ) async throws -> String {
    guard let url = URL(string: rpcUrl) else {
      throw RainSDKError.invalidRpcUrl(rpcUrl)
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
        // Preserve the node's own message; classified via RainSDKError.from below.
        throw NSError(
          domain: "eth.rpc",
          code: code,
          userInfo: [NSLocalizedDescriptionKey: message]
        )
      }

      guard let result = response["result"] as? String else {
        throw RainSDKError.internalLogicError(
          details: "Unexpected RPC result for method \(method)"
        )
      }
      return result
    } catch let error as RainSDKError {
      throw error
    } catch {
      RainLogger.error("Rain SDK: Privy JSON-RPC failure for \(method): \(error)")
      throw RainSDKError.from(underlying: error)
    }
  }
}
