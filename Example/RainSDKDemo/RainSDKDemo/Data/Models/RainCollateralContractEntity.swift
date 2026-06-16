import Foundation

/// Entity for a Rain collateral contract (e.g. from GET /v1/issuing/users/{userId}/contracts).
public protocol RainCollateralContractEntity {
  var contractId: String? { get }
  var network: String? { get }
  var chainId: Int? { get }
  var address: String? { get }
  var controllerAddress: String? { get }
  /// Admins of the collateral contract; the first is used as the withdrawal-signature
  /// `adminAddress` (required by the Rain dev API).
  var adminAddresses: [String]? { get }
  var creditLimit: Double? { get }
  var tokensEntity: [RainTokenEntity]? { get }
}

/// Entity for a Rain token within a collateral contract.
public protocol RainTokenEntity {
  var address: String? { get }
  var name: String? { get }
  var symbol: String? { get }
  var decimals: Double? { get }
  var logo: String? { get }
  var balance: Double? { get }
  var exchangeRate: Double? { get }
  var advanceRate: Double? { get }
  var availableUsdBalance: Double? { get }
}
