import Foundation

// sourcery: AutoMockable
public protocol RainCollateralContractEntity {
  var contractId: String { get }
  var network: String { get }
  var chainId: Int { get }
  var address: String { get }
  var controllerAddress: String? { get }
  var creditLimit: Double { get }
  var tokensEntity: [RainTokenEntity] { get }
}

public protocol RainTokenEntity {
  var address: String { get }
  var name: String? { get }
  var symbol: String? { get }
  var decimals: Double? { get }
  var logo: String? { get }
  var balance: String { get }
  var exchangeRate: Double { get }
  var advanceRate: Double { get }
  var availableUsdBalance: Double { get }
  
  init(
    address: String,
    name: String?,
    symbol: String?,
    decimals: Double?,
    logo: String?,
    balance: String,
    exchangeRate: Double,
    advanceRate: Double
  )
}
