import Foundation

// MARK: - Demo model (Decodable)
// All properties optional (exclude id if any) so decoding succeeds when API omits keys.

/// Decodable response for a token; conforms to RainTokenEntity.
struct RainTokenResponse: Decodable, RainTokenEntity, Hashable {
  let address: String?
  let name: String?
  let symbol: String?
  let decimals: Double?
  let logo: String?
  let balance: Double?
  let exchangeRate: Double?
  let advanceRate: Double?
  let availableUsdBalance: Double?
}

/// Canonical demo model for a collateral contract; conforms to RainCollateralContractEntity.
/// Built from the Rain dev API DTO (`RainContractDto`) — see `toCollateralContractResponse()`.
struct RainCollateralContractResponse: Decodable, Hashable {
  let contractId: String?
  let network: String?
  let chainId: Int?
  let address: String?
  let controllerAddress: String?
  let adminAddresses: [String]?
  let creditLimit: Double?
  let tokens: [RainTokenResponse]?

  var tokensEntity: [RainTokenEntity]? { tokens }

  func toAssetModels() -> [AssetModel] {
    (tokens ?? []).map { AssetModel(rainCollateralAsset: $0) }
  }
}

// MARK: - Wire DTOs (Rain dev API)

/// Decodable wire model for `GET /v1/issuing/users/{userId}/contracts`. Rain returns an array
/// of these; the demo uses the first.
///
/// Note the Rain contracts endpoint returns only token `address`/`balance`/`exchangeRate`/
/// `advanceRate` — no symbol/decimals/logo metadata (unlike the old LF endpoint). Those are
/// left nil here for the repository to resolve on-chain via the SDK.
struct RainContractDto: Decodable {
  let id: String?
  let chainId: Int?
  let controllerAddress: String?
  let proxyAddress: String?
  let depositAddress: String?
  let adminAddresses: [String]?
  let contractVersion: Int?
  let tokens: [RainContractTokenDto]?

  /// Maps the Rain DTO onto the demo's canonical model. `address` is the proxy address (what
  /// the demo treats as the collateral contract address); `controllerAddress` is kept separate.
  func toCollateralContractResponse() -> RainCollateralContractResponse {
    RainCollateralContractResponse(
      contractId: id,
      network: nil,
      chainId: chainId,
      address: proxyAddress,
      controllerAddress: controllerAddress,
      adminAddresses: adminAddresses,
      creditLimit: nil,
      tokens: (tokens ?? []).map { $0.toTokenResponse() }
    )
  }
}

/// Decodable wire model for a token inside a Rain contract.
struct RainContractTokenDto: Decodable {
  let address: String?
  // Rain returns balance as a string (e.g. "0.0"); the demo model keeps it as a Double.
  let balance: String?
  let exchangeRate: Double?
  let advanceRate: Double?

  func toTokenResponse() -> RainTokenResponse {
    RainTokenResponse(
      address: address,
      // Rain's contracts endpoint omits token name/symbol/decimals/logo; left nil for the
      // repository to resolve on-chain via the SDK token registry / chain reader.
      name: nil,
      symbol: nil,
      decimals: nil,
      logo: nil,
      balance: balance.flatMap { Double($0) } ?? 0,
      exchangeRate: exchangeRate,
      advanceRate: advanceRate,
      availableUsdBalance: nil
    )
  }
}
