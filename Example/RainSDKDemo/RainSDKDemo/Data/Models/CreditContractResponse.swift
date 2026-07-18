import Foundation
import RainCore

// MARK: - Demo models
// The Rain REST API now lives inside the SDK (`RainSdk.fetchCollateralContract*`), which
// returns `RainCore.RainCollateralContract` with tokens already enriched (name / symbol /
// decimals from the SDK token store or an on-chain read). These structs remain the demo's
// canonical view models; they are built from the core model instead of decoded off the wire.

/// Demo model for a token; conforms to RainTokenEntity.
struct RainTokenResponse: RainTokenEntity, Hashable {
  let address: String?
  let name: String?
  let symbol: String?
  let decimals: Double?
  let logo: String?
  let balance: Double?
  let exchangeRate: Double?
  let advanceRate: Double?
  let availableUsdBalance: Double?

  init(token: RainCollateralToken) {
    address = token.address
    name = token.name
    symbol = token.symbol
    decimals = token.decimals.map(Double.init)
    logo = nil
    balance = token.balanceAmount.map { NSDecimalNumber(decimal: $0).doubleValue } ?? 0
    exchangeRate = token.exchangeRate
    advanceRate = token.advanceRate
    availableUsdBalance = nil
  }
}

/// Canonical demo model for a collateral contract; conforms to RainCollateralContractEntity.
struct RainCollateralContractResponse: Hashable {
  let contractId: String?
  let network: String?
  let chainId: Int?
  let address: String?
  let controllerAddress: String?
  let adminAddresses: [String]?
  let creditLimit: Double?
  let tokens: [RainTokenResponse]?

  var tokensEntity: [RainTokenEntity]? { tokens }

  /// Maps the SDK's contract model onto the demo's view model. `address` is the proxy
  /// address (what the demo treats as the collateral contract address);
  /// `controllerAddress` is kept separate.
  init(contract: RainCollateralContract) {
    contractId = contract.id
    network = nil
    chainId = contract.chainId
    address = contract.proxyAddress
    controllerAddress = contract.controllerAddress
    adminAddresses = contract.adminAddresses
    creditLimit = nil
    tokens = contract.tokens.map(RainTokenResponse.init(token:))
  }

  func toAssetModels() -> [AssetModel] {
    (tokens ?? []).map { AssetModel(rainCollateralAsset: $0) }
  }
}
