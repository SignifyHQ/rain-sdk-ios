import Foundation

/// Owns per-chain token reference data plus a runtime enrichment cache.
///
/// Seeded from `TokenRegistry` defaults and extendable at runtime via `register(_:)`
/// (host apps adding their own tokens). Unknown `.contract` tokens are enriched on demand
/// by reading `decimals()` / `symbol()` through a `ChainReader`, then cached so a given
/// token is only enriched once.
///
/// An `actor` because enrichment fans out async RPC across task groups; actor isolation
/// gives reentrant-safe access to the registry and cache without manual locking.
actor TokenMetadataStore {
  private let chainReader: ChainReader

  /// Known tokens per chain: built-in registry plus host-registered. Insertion order is
  /// preserved (registry order first, then registrations) so balance reads are deterministic.
  private var knownTokens: [Int: [TokenInfo]]

  /// Tokens discovered and enriched at runtime, keyed by chain ID then lowercased address.
  private var enrichmentCache: [Int: [String: TokenInfo]] = [:]

  init(chainReader: ChainReader, seedTokens: [TokenInfo] = []) {
    self.chainReader = chainReader
    self.knownTokens = TokenRegistry.tokensByChainId
    for token in seedTokens {
      Self.upsert(token, into: &self.knownTokens)
    }
  }

  /// Adds host-supplied tokens. A token replaces any existing entry with the same
  /// address (case-insensitive) on the same chain.
  func register(_ tokens: [TokenInfo]) {
    for token in tokens {
      Self.upsert(token, into: &knownTokens)
    }
  }

  /// Native currency for a chain (gas token metadata).
  func nativeCurrency(for chainId: Int) -> NativeCurrency {
    TokenRegistry.nativeCurrency(for: chainId)
  }

  /// All known tokens for a chain (registry + host-registered), in deterministic order.
  func registeredTokens(for chainId: Int) -> [TokenInfo] {
    knownTokens[chainId] ?? []
  }

  /// Resolves metadata for a contract token: known tokens first, then the enrichment
  /// cache, then a one-time on-chain `decimals()` / `symbol()` read (cached on success).
  func tokenInfo(chainId: Int, address: String) async -> TokenInfo {
    let key = address.lowercased()
    if let known = knownTokens[chainId]?.first(where: { $0.address.lowercased() == key }) {
      return known
    }
    if let cached = enrichmentCache[chainId]?[key] {
      return cached
    }
    let enriched = await enrich(chainId: chainId, address: address)
    enrichmentCache[chainId, default: [:]][key] = enriched
    return enriched
  }

  // MARK: - Enrichment

  /// Reads `decimals()`, `symbol()` and `name()` in parallel. A failed `decimals()` falls
  /// back to the default; a failed `symbol()` / `name()` leaves that field `nil`.
  private func enrich(chainId: Int, address: String) async -> TokenInfo {
    async let decimalsTask = chainReader.getDecimals(chainId: chainId, tokenAddress: address)
    async let symbolTask = chainReader.getSymbol(chainId: chainId, tokenAddress: address)
    async let nameTask = chainReader.getName(chainId: chainId, tokenAddress: address)

    let decimals = (try? await decimalsTask) ?? Constants.ERC20.defaultDecimals
    let symbol = (try? await symbolTask) ?? nil
    let name = (try? await nameTask) ?? nil

    return TokenInfo(
      chainId: chainId,
      address: address,
      symbol: symbol,
      decimals: decimals,
      name: name
    )
  }

  // MARK: - Helpers

  private static func upsert(_ token: TokenInfo, into store: inout [Int: [TokenInfo]]) {
    let key = token.address.lowercased()
    var list = store[token.chainId] ?? []
    if let index = list.firstIndex(where: { $0.address.lowercased() == key }) {
      list[index] = token
    } else {
      list.append(token)
    }
    store[token.chainId] = list
  }
}
