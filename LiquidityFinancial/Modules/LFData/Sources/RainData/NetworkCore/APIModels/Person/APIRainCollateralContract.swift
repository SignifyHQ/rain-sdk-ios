import Foundation
import RainDomain

public struct APIRainCollateralContract: Decodable {
  public let contractId: String
  public let network: String
  public let chainId: Int
  public let address: String
  public let controllerAddress: String?
  public let tokens: [APIRainToken]
}

public struct APIRainToken: Decodable, RainTokenEntity {
  public let address: String
  public let name: String?
  public let symbol: String?
  public let decimals: Double?
  
  public init(address: String, name: String?, symbol: String?, decimals: Double?) {
    self.address = address
    self.name = name
    self.symbol = symbol
    self.decimals = decimals
  }
}

extension APIRainCollateralContract: RainCollateralContractEntity {
  public var tokensEntity: [RainTokenEntity] {
    tokens
  }
}
