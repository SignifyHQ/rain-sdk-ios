import Foundation

// MARK: - Response DTOs (Decodable)
// Decode with JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase so keys like contract_id → contractId.
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

/// Decodable response for a collateral contract; conforms to RainCollateralContractEntity.
struct RainCollateralContractResponse: Decodable, Hashable {
  let contractId: String?
  let network: String?
  let chainId: Int?
  let address: String?
  let controllerAddress: String?
  let creditLimit: Double?
  let tokens: [RainTokenResponse]?
  
  var tokensEntity: [RainTokenEntity]? { tokens }

  func toAssetModels() -> [AssetModel] {
    (tokens ?? []).map { AssetModel(rainCollateralAsset: $0) }
  }
}
