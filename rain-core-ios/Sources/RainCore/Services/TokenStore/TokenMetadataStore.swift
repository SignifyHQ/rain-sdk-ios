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
public actor TokenMetadataStore {
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
  public func register(_ tokens: [TokenInfo]) {
    for token in tokens {
      Self.upsert(token, into: &knownTokens)
    }
  }

  /// Native currency for a chain (gas token metadata).
  public func nativeCurrency(for chainId: Int) -> NativeCurrency {
    TokenRegistry.nativeCurrency(for: chainId)
  }

  /// Native currency for a chain, or `nil` when the chain is not in the registry. Unlike
  /// ``nativeCurrency(for:)`` this never falls back to an ETH-like default, so callers that must
  /// not show a wrong symbol (e.g. transaction history) can tell "unknown chain" apart.
  public func nativeCurrencyOrNil(for chainId: Int) -> NativeCurrency? {
    TokenRegistry.nativeCurrencyByChainId[chainId]
  }

  /// All known tokens for a chain (registry + host-registered), in deterministic order.
  public func registeredTokens(for chainId: Int) -> [TokenInfo] {
    knownTokens[chainId] ?? []
  }

  /// Resolves metadata for a contract token: known tokens first, then the enrichment
  /// cache, then a one-time on-chain `decimals()` / `symbol()` read (cached on success).
  public func tokenInfo(chainId: Int, address: String) async -> TokenInfo {
    let key = address.lowercased()
    if let known = knownTokens[chainId]?.first(where: { $0.address.lowercased() == key }) {
      return known
    }
    if let cached = enrichmentCache[chainId]?[key] {
      return cached
    }
    let enriched = await enrich(chainId: chainId, address: address)

    // A fallback `decimals` is a guess, not a fact: caching it would pin a balance that is
    // wrong by orders of magnitude for the rest of the process. Retry on the next lookup.
    guard enriched.decimalsResolved else { return enriched.info }

    enrichmentCache[chainId, default: [:]][key] = enriched.info
    return enriched.info
  }

  /// A contract token's decimals, or `nil` when they could not be established — the token is not
  /// in the registry and its on-chain `decimals()` read failed.
  ///
  /// Unlike ``tokenInfo(chainId:address:)``, this never substitutes the 18-decimal default.
  /// Callers that scale a *money amount* must use this: on an approval a guessed 18 against a
  /// 6-decimal token would silently approve 10^12 times the intended allowance, and `approve`
  /// has no balance to fail against, so nothing downstream would catch it.
  public func decimals(chainId: Int, address: String) async -> Int? {
    let key = address.lowercased()
    if let known = knownTokens[chainId]?.first(where: { $0.address.lowercased() == key }) {
      return known.decimals
    }
    if let cached = enrichmentCache[chainId]?[key] {
      return cached.decimals
    }
    let enriched = await enrich(chainId: chainId, address: address)
    guard enriched.decimalsResolved else { return nil }

    enrichmentCache[chainId, default: [:]][key] = enriched.info
    return enriched.info.decimals
  }

  // MARK: - Enrichment

  /// An enrichment result plus whether `decimals` came from the chain or the fallback.
  private struct Enriched {
    let info: TokenInfo
    let decimalsResolved: Bool
  }

  /// Reads `decimals()`, `symbol()` and `name()` in parallel. A failed `decimals()` falls
  /// back to the default; a failed `symbol()` / `name()` leaves that field `nil`.
  private func enrich(chainId: Int, address: String) async -> Enriched {
    async let decimalsTask = chainReader.getDecimals(chainId: chainId, tokenAddress: address)
    async let symbolTask = chainReader.getSymbol(chainId: chainId, tokenAddress: address)
    async let nameTask = chainReader.getName(chainId: chainId, tokenAddress: address)

    let resolvedDecimals = try? await decimalsTask
    let symbol = (try? await symbolTask) ?? nil
    let name = (try? await nameTask) ?? nil

    if resolvedDecimals == nil {
      // Falling back here misreports the balance by orders of magnitude for any
      // non-18-decimal token, so it must never fail silently.
      RainLogger.warning(
        "Rain SDK: decimals() read failed for token=\(address) chainId=\(chainId) — "
          + "falling back to \(Constants.ERC20.defaultDecimals)"
      )
    }

    return Enriched(
      info: TokenInfo(
        chainId: chainId,
        address: address,
        symbol: symbol,
        decimals: resolvedDecimals ?? Constants.ERC20.defaultDecimals,
        name: name
      ),
      decimalsResolved: resolvedDecimals != nil
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
