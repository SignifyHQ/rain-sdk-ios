import Foundation
import Web3

/// Thin Solana JSON-RPC helper layered on the shared `JsonRpcClient`. Solana RPC returns JSON
/// objects/numbers rather than the hex strings EVM uses, so it needs the raw `call()` surface
/// (not `callForHexResult`).
///
/// Covers the three calls the Solana wallet path needs: the native balance, a recent blockhash
/// for an outgoing transfer, and the signature of a just-submitted transfer.
internal final class SolanaRpcClient: Sendable {
  private let jsonRpcClient: JsonRpcClient
  private let networkConfigResolver: @Sendable (Int) -> NetworkConfig?

  internal init(
    jsonRpcClient: JsonRpcClient = JsonRpcClient(),
    networkConfigResolver: @escaping @Sendable (Int) -> NetworkConfig?
  ) {
    self.jsonRpcClient = jsonRpcClient
    self.networkConfigResolver = networkConfigResolver
  }

  /// Convenience init that builds the resolver from a list of network configs.
  internal convenience init(
    jsonRpcClient: JsonRpcClient = JsonRpcClient(),
    networkConfigs: [NetworkConfig]
  ) {
    let lookup = Dictionary(uniqueKeysWithValues: networkConfigs.map { ($0.chainId, $0) })
    self.init(jsonRpcClient: jsonRpcClient, networkConfigResolver: { lookup[$0] })
  }

  /// Native SOL balance in lamports via `getBalance`.
  func getBalanceLamports(chainId: Int, address: String) async throws -> BigUInt {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    let response = try await jsonRpcClient.call(rpcUrl: rpcUrl, method: "getBalance", params: [address])
    guard let result = response["result"] as? [String: Any],
          let value = result["value"] as? NSNumber else {
      throw RainSDKError.internalLogicError(details: "Unexpected getBalance response for \(address)")
    }
    // Parse via the decimal string form: `BigUInt(UInt64)` is ambiguous once BigInt is in
    // module scope, and the string init is the codebase's established idiom.
    return BigUInt(value.stringValue) ?? 0
  }

  /// Most recent blockhash via `getLatestBlockhash`, used as a transfer's `recentBlockhash`.
  func getLatestBlockhash(chainId: Int) async throws -> String {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    let response = try await jsonRpcClient.call(
      rpcUrl: rpcUrl,
      method: "getLatestBlockhash",
      params: [["commitment": "finalized"]]
    )
    guard let result = response["result"] as? [String: Any],
          let value = result["value"] as? [String: Any],
          let blockhash = value["blockhash"] as? String,
          !blockhash.isEmpty else {
      throw RainSDKError.internalLogicError(details: "Unexpected getLatestBlockhash response")
    }
    return blockhash
  }

  /// The most recent transaction signature involving `address`, or `nil` if none. Used as a
  /// defensive fallback when Turnkey's status response carries no Solana signature.
  func getLatestSignature(chainId: Int, address: String) async throws -> String? {
    let rpcUrl = try resolveRpcUrl(chainId: chainId)
    let response = try await jsonRpcClient.call(
      rpcUrl: rpcUrl,
      method: "getSignaturesForAddress",
      params: [address, ["limit": 1]]
    )
    guard let results = response["result"] as? [[String: Any]],
          let first = results.first,
          let signature = first["signature"] as? String,
          !signature.isEmpty else {
      return nil
    }
    return signature
  }

  /// Resolves and validates the RPC URL for `chainId`, mirroring `EVMChainReader`.
  private func resolveRpcUrl(chainId: Int) throws -> String {
    guard let config = networkConfigResolver(chainId) else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: "")
    }
    guard URL(string: config.rpcUrl) != nil else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: config.rpcUrl)
    }
    return config.rpcUrl
  }
}
