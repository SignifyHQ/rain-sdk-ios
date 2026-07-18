import Foundation

/// Orchestrates the Rain issuing API: composes credentials (`RainApiConfigStore`), the CST
/// cache (`RainSessionManager`) and the HTTP client (`RainApiClient`), and enriches contract
/// tokens through the SDK token store. Mirrors Android's `RainApiService`.
///
/// A Bearer call rejected as `.unauthorized` invalidates the cached CST and retries exactly
/// once with a freshly minted token before rethrowing.
internal final class RainApiService: Sendable {
  private let configStore: RainApiConfigStore
  private let tokenStore: TokenMetadataStore
  private let chainReader: ChainReader
  private let client: RainApiClient
  private let sessionManager: RainSessionManager

  init(
    configStore: RainApiConfigStore,
    tokenStore: TokenMetadataStore,
    chainReader: ChainReader,
    client: RainApiClient = RainApiClient()
  ) {
    self.configStore = configStore
    self.tokenStore = tokenStore
    self.chainReader = chainReader
    self.client = client
    let baseURL = configStore.baseURL
    self.sessionManager = RainSessionManager { credentials in
      try await client.createSession(baseURL: baseURL, credentials: credentials)
    }
  }

  func fetchCollateralContracts() async throws -> [RainCollateralContract] {
    let contracts = try await withCst { cst, credentials in
      try await self.client.getContracts(
        baseURL: self.configStore.baseURL,
        cst: cst,
        userId: credentials.userId
      )
    }
    var enriched: [RainCollateralContract] = []
    enriched.reserveCapacity(contracts.count)
    for contract in contracts {
      enriched.append(await enrichTokens(of: contract))
    }
    return enriched
  }

  func fetchAdminSignature(
    chainId: Int,
    tokenAddress: String,
    amountBaseUnits: String,
    adminAddress: String,
    recipientAddress: String,
    isAmountNative: Bool
  ) async throws -> RainAdminSignature {
    try await withCst { cst, credentials in
      try await self.client.getWithdrawalSignature(
        baseURL: self.configStore.baseURL,
        cst: cst,
        userId: credentials.userId,
        chainId: chainId,
        tokenAddress: tokenAddress,
        amountBaseUnits: amountBaseUnits,
        adminAddress: adminAddress,
        recipientAddress: recipientAddress,
        isAmountNative: isAmountNative
      )
    }
  }

  // MARK: - Internals

  private func withCst<T>(
    _ block: (_ cst: String, _ credentials: RainApiCredentials) async throws -> T
  ) async throws -> T {
    let credentials = try configStore.credentials()
    let cst = try await sessionManager.validToken(for: credentials)
    do {
      return try await block(cst, credentials)
    } catch RainSDKError.unauthorized {
      // The CST may have been revoked before its expiry — re-mint once and retry.
      await sessionManager.invalidate()
      let fresh = try configStore.credentials()
      return try await block(try await sessionManager.validToken(for: fresh), fresh)
    }
  }

  /// Fills token `name`/`symbol`/`decimals`: known tokens (registry + host-registered) first,
  /// else direct on-chain reads. Best-effort and concurrent per token: a failed read leaves
  /// that field nil — never a fabricated default, since wrong decimals would corrupt the
  /// caller's base-unit math. (This is deliberately NOT `tokenStore.tokenInfo`, whose
  /// enrichment falls back to 18 decimals on failure.) Solana chains are skipped — the
  /// enrichment path is EVM-only.
  private func enrichTokens(of contract: RainCollateralContract) async -> RainCollateralContract {
    guard !contract.tokens.isEmpty, !SolanaChains.isSolana(contract.chainId) else { return contract }

    let chainId = contract.chainId
    let known = await tokenStore.registeredTokens(for: chainId)
    let reader = chainReader
    let enriched = await withTaskGroup(of: (Int, RainCollateralToken).self) { group in
      for (index, token) in contract.tokens.enumerated() {
        group.addTask {
          if let info = known.first(where: { $0.address.lowercased() == token.address.lowercased() }) {
            return (
              index,
              RainCollateralToken(
                address: token.address,
                balance: token.balance,
                exchangeRate: token.exchangeRate,
                advanceRate: token.advanceRate,
                name: info.name,
                symbol: info.symbol,
                decimals: info.decimals
              )
            )
          }
          async let decimalsRead = reader.getDecimals(chainId: chainId, tokenAddress: token.address)
          async let symbolRead = reader.getSymbol(chainId: chainId, tokenAddress: token.address)
          async let nameRead = reader.getName(chainId: chainId, tokenAddress: token.address)
          let decimals = try? await decimalsRead
          let symbol = (try? await symbolRead) ?? nil
          let name = (try? await nameRead) ?? nil
          return (
            index,
            RainCollateralToken(
              address: token.address,
              balance: token.balance,
              exchangeRate: token.exchangeRate,
              advanceRate: token.advanceRate,
              name: name,
              symbol: symbol,
              decimals: decimals
            )
          )
        }
      }
      var results = contract.tokens
      for await (index, token) in group {
        results[index] = token
      }
      return results
    }

    return RainCollateralContract(
      id: contract.id,
      chainId: contract.chainId,
      proxyAddress: contract.proxyAddress,
      controllerAddress: contract.controllerAddress,
      depositAddress: contract.depositAddress,
      adminAddresses: contract.adminAddresses,
      contractVersion: contract.contractVersion,
      tokens: enriched
    )
  }
}
