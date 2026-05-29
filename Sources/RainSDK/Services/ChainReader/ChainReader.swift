import Foundation

/// Provider-agnostic, read-only on-chain query surface.
///
/// One place for reading state from any chain the SDK consumer has configured. Used by
/// `TurnkeyWalletProviderAdapter` to fill in balances on chains outside the Turnkey
/// `get-balances` allowlist, and available to any future wallet provider adapter that
/// needs the same fallback.
///
/// V1 surface is balances. Future reads (token metadata, allowances, generic `eth_call`
/// wrappers) belong on this protocol so call sites don't fragment.
///
/// Implementations exist per chain family. `EVMChainReader` covers all EIP-155 chains
/// via JSON-RPC. A future Solana/Stellar reader can conform alongside it; until then,
/// `chainId: Int` matches the rest of the SDK's EVM-centric typing.
internal protocol ChainReader: Sendable {
  /// Native balance (e.g. ETH on Ethereum, AVAX on Avalanche).
  /// - Returns: Balance in human-readable form (e.g. `1.5` for 1.5 ETH).
  func getNativeBalance(chainId: Int, walletAddress: String) async throws -> Double

  /// Single ERC-20 balance via `balanceOf(address)`.
  /// - Parameter decimals: Token decimal places; defaults to `Constants.ERC20.defaultDecimals` if nil.
  func getERC20Balance(
    chainId: Int,
    tokenAddress: String,
    walletAddress: String,
    decimals: Int?
  ) async throws -> Double

  /// Batched balances for many tokens on one chain, in a single round-trip when possible.
  /// - Parameter tokens: ERC-20 tokens to query. The native balance is always included.
  /// - Returns: One `Balance` per successfully-read token plus the native balance
  ///   (`Token.native`). Tokens whose `balanceOf` reverts are omitted; zero balances are
  ///   retained (zero-filtering is the caller's responsibility).
  func getBalances(
    chainId: Int,
    walletAddress: String,
    tokens: [TokenInfo]
  ) async throws -> [Balance]

  /// Reads a single balance (native or a contract token) as a rich `Balance`.
  /// - Parameter tokenInfo: Pre-resolved metadata for a `.contract` token (decimals / symbol /
  ///   name); ignored for `.native`. When `nil` for a contract token, defaults are used.
  func getBalance(
    chainId: Int,
    walletAddress: String,
    token: Token,
    tokenInfo: TokenInfo?
  ) async throws -> Balance

  /// Reads an ERC-20 token's `decimals()`. Used to enrich tokens not in the registry.
  func getDecimals(chainId: Int, tokenAddress: String) async throws -> Int

  /// Reads an ERC-20 token's `symbol()`. Returns `nil` if the call reverts or returns
  /// an undecodable payload. Used to enrich tokens not in the registry.
  func getSymbol(chainId: Int, tokenAddress: String) async throws -> String?
}
