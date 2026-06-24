import Foundation
import Web3

/// Solana implementation of `ChainReader` — the "future Solana reader" anticipated by the
/// protocol docs. Reads native SOL balances over Solana JSON-RPC (`getBalance`).
///
/// SPL token balances are out of scope for now: the contract/ERC-20 paths throw, mirroring how
/// the EVM reader rejects non-EVM input rather than returning misleading data.
internal final class SolanaChainReader: ChainReader, @unchecked Sendable {
  private let solanaRpcClient: SolanaRpcClient

  internal init(solanaRpcClient: SolanaRpcClient) {
    self.solanaRpcClient = solanaRpcClient
  }

  /// Convenience init that builds the RPC client from a list of network configs.
  internal convenience init(networkConfigs: [NetworkConfig], jsonRpcClient: JsonRpcClient = JsonRpcClient()) {
    self.init(solanaRpcClient: SolanaRpcClient(jsonRpcClient: jsonRpcClient, networkConfigs: networkConfigs))
  }

  func getNativeBalance(chainId: Int, walletAddress: String) async throws -> Double {
    try validate(solanaAddress: walletAddress)
    let lamports = try await solanaRpcClient.getBalanceLamports(chainId: chainId, address: walletAddress)
    return SolanaConverter.lamportsToSolDouble(lamports)
  }

  func getBalance(
    chainId: Int,
    walletAddress: String,
    token: Token,
    tokenInfo: TokenInfo?
  ) async throws -> Balance {
    try validate(solanaAddress: walletAddress)
    switch token {
    case .native:
      let lamports = try await solanaRpcClient.getBalanceLamports(chainId: chainId, address: walletAddress)
      let native = SolanaChains.nativeCurrency
      return Balance(
        token: .native,
        chainId: chainId,
        rawAmount: lamports,
        decimals: native.decimals,
        symbol: native.symbol,
        name: native.name
      )
    case .contract:
      throw RainSDKError.internalLogicError(
        details: "SPL token balances are not supported on Solana chainId=\(chainId)"
      )
    }
  }

  func getBalances(
    chainId: Int,
    walletAddress: String,
    tokens: [TokenInfo]
  ) async throws -> [Balance] {
    [try await getBalance(chainId: chainId, walletAddress: walletAddress, token: .native, tokenInfo: nil)]
  }

  func getERC20Balance(
    chainId: Int,
    tokenAddress: String,
    walletAddress: String,
    decimals: Int?
  ) async throws -> Double {
    throw RainSDKError.internalLogicError(details: "ERC-20 reads are not supported on Solana")
  }

  func getDecimals(chainId: Int, tokenAddress: String) async throws -> Int {
    throw RainSDKError.internalLogicError(details: "getDecimals is not supported on Solana")
  }

  func getSymbol(chainId: Int, tokenAddress: String) async throws -> String? {
    throw RainSDKError.internalLogicError(details: "getSymbol is not supported on Solana")
  }

  func getName(chainId: Int, tokenAddress: String) async throws -> String? {
    throw RainSDKError.internalLogicError(details: "getName is not supported on Solana")
  }

  private func validate(solanaAddress address: String) throws {
    let valid = ((try? Base58.decode(address))?.count == 32)
    guard valid else {
      throw RainSDKError.internalLogicError(details: "Invalid Solana wallet address: \(address)")
    }
  }
}
