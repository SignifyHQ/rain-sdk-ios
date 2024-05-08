import Foundation

// sourcery: AutoMockable
public protocol RainCollateralContractEntity {
  var contractId: String { get }
  var network: String { get }
  var chainId: Int { get }
  var address: String { get }
  var controllerAddress: String? { get }
  var tokens: [RainTokenEntity] { get }
}

public protocol RainTokenEntity {
  var address: String { get }
  var name: String? { get }
  var symbol: String? { get }
  var decimals: Double? { get }
  
  init(
    address: String,
    name: String?,
    symbol: String?,
    decimals: Double?
  )
}
