import Foundation

/// Orchestrates the Rain issuing API: composes credentials (`RainApiConfigStore`) with the HTTP
/// client (`RainApiClient`) and enriches contract tokens through the SDK token store.
///
/// Every call authenticates directly with the program key (`Api-Key` header) — the CST session
/// layer was removed 2026-09-15 (client session tokens are not enabled for Rain's tenants), so
/// an `.unauthorized` is terminal: retrying with the same key cannot succeed.
internal final class RainApiService: Sendable {
  private let configStore: RainApiConfigStore
  private let tokenStore: TokenMetadataStore
  private let chainReader: ChainReader
  private let client: RainApiClient

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
  }

  func fetchCollateralContracts() async throws -> [RainCollateralContract] {
    let contracts = try await client.getContracts(
      baseURL: configStore.baseURL,
      credentials: try configStore.credentials()
    )
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
    try await client.getWithdrawalSignature(
      baseURL: configStore.baseURL,
      credentials: try configStore.credentials(),
      chainId: chainId,
      tokenAddress: tokenAddress,
      amountBaseUnits: amountBaseUnits,
      adminAddress: adminAddress,
      recipientAddress: recipientAddress,
      isAmountNative: isAmountNative
    )
  }

  // MARK: - Internals

  /// Fills token `name`/`symbol`/`decimals`: known tokens (registry + host-registered) first,
  /// else direct on-chain reads. Best-effort and concurrent per token: a failed read leaves
  /// that field nil — never a fabricated default, since wrong decimals would corrupt the
  /// caller's base-unit math. (This is deliberately NOT `tokenStore.tokenInfo`, whose
  /// enrichment falls back to 18 decimals on failure.) On Solana chains only the registry
  /// is consulted — the on-chain read path is EVM-only, and an SPL mint carries no on-chain
  /// symbol anyway, so host-registered metadata is the sole naming source there.
  private func enrichTokens(of contract: RainCollateralContract) async -> RainCollateralContract {
    guard !contract.tokens.isEmpty else { return contract }

    let chainId = contract.chainId
    let known = await tokenStore.registeredTokens(for: chainId)
    if SolanaChains.isSolana(chainId) {
      let tokens = contract.tokens.map { token in
        known.first(where: { $0.address.lowercased() == token.address.lowercased() }).map { info in
          RainCollateralToken(
            address: token.address,
            balance: token.balance,
            exchangeRate: token.exchangeRate,
            advanceRate: token.advanceRate,
            name: info.name,
            symbol: info.symbol,
            decimals: info.decimals
          )
        } ?? token
      }
      return contractReplacingTokens(contract, with: tokens)
    }
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

    return contractReplacingTokens(contract, with: enriched)
  }

  private func contractReplacingTokens(
    _ contract: RainCollateralContract,
    with tokens: [RainCollateralToken]
  ) -> RainCollateralContract {
    RainCollateralContract(
      id: contract.id,
      chainId: contract.chainId,
      proxyAddress: contract.proxyAddress,
      controllerAddress: contract.controllerAddress,
      depositAddress: contract.depositAddress,
      adminAddresses: contract.adminAddresses,
      contractVersion: contract.contractVersion,
      tokens: tokens
    )
  }
}
